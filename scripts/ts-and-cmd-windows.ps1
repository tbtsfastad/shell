$ErrorActionPreference = 'Stop'
$version = '0.3.0'

function Show-Usage {
    Write-Host '用法 ts-and-cmd run [--debug] [设备序列号 | -d 设备序列号]'
    Write-Host '     ts-and-cmd build <apk|appbundle> [--debug]'
    Write-Host '默认构建 Release，选择 adb devices 中第一台可用设备。'
    Write-Host '启动后持续输出应用日志。按 q 退出 App，按 Ctrl+C 仅停止查看。'
}

function Stop-InvalidArguments($Message) {
    [Console]::Error.WriteLine("ts-and-cmd: $Message")
    Show-Usage
    exit 2
}

function Get-SdkDirectory {
    if (Test-Path -LiteralPath 'local.properties' -PathType Leaf) {
        $properties = [string](Get-Content -LiteralPath 'local.properties' -Encoding UTF8 -Raw)
        $settings = [regex]::Matches($properties, '(?m)^[ \t]*sdk\.dir[ \t]*[=:][ \t]*([^\r\n]*)')
        if ($settings.Count -gt 0 -and $settings[-1].Groups[1].Value) {
            return [regex]::Replace($settings[-1].Groups[1].Value, '\\(?:u([0-9a-fA-F]{4})|(.))', {
                param($Escape)
                if ($Escape.Groups[1].Success) { return [char][Convert]::ToInt32($Escape.Groups[1].Value, 16) }
                return $Escape.Groups[2].Value
            })
        }
    }

    if ($env:ANDROID_HOME) { return $env:ANDROID_HOME }
    if ($env:ANDROID_SDK_ROOT) { return $env:ANDROID_SDK_ROOT }
    return Join-Path $env:LOCALAPPDATA 'Android/Sdk'
}

function Select-Device($Adb, $Requested) {
    $output = & $Adb devices
    if ($LASTEXITCODE -ne 0) { throw '无法查询 ADB 设备' }
    $foundState = '未连接'
    foreach ($line in $output) {
        if ($line -notmatch '^(\S+)\t(.+)$') { continue }
        $serial = $Matches[1]
        $state = $Matches[2].Trim()
        if ($state -ceq 'device' -and (!$Requested -or $serial -ceq $Requested)) { return $serial }
        if ($serial -ceq $Requested) { $foundState = $state }
    }
    if ($Requested) { throw "设备 $Requested 不可用（$foundState）" }
    throw "ADB 没有可用设备。`n$($output -join "`n")"
}

function Get-BuiltApk($Variant) {
    $directory = Join-Path (Get-Location).ProviderPath "app/build/outputs/apk/$Variant"
    $metadata = Join-Path $directory 'output-metadata.json'
    if (!(Test-Path -LiteralPath $metadata -PathType Leaf)) { throw "找不到 APK 构建信息（$metadata）" }
    $data = Get-Content -LiteralPath $metadata -Encoding UTF8 -Raw | ConvertFrom-Json
    if ($data.elements -isnot [Array]) { throw "APK 构建信息格式无效（$metadata）" }
    if ($data.variantName -cne $Variant) { throw "构建变体为 $($data.variantName)，预期为 $Variant" }

    $artifacts = $data.elements
    if ($artifacts.Count -ne 1) {
        $artifacts = @($artifacts | Where-Object { $_.filters -is [Array] -and $_.filters.Count -eq 0 })
    }
    if ($artifacts.Count -ne 1 -or !$artifacts[0].outputFile) { throw '未找到唯一可安装的 APK' }
    $apk = Join-Path $directory $artifacts[0].outputFile
    if (!(Test-Path -LiteralPath $apk -PathType Leaf)) { throw "找不到 Gradle 生成的 APK（$apk）" }
    return $apk
}

function Start-App($Adb, $Serial, $Package) {
    $intent = @('-a', 'android.intent.action.MAIN', '-c', 'android.intent.category.LAUNCHER')
    $resolved = & $Adb -s $Serial shell cmd package resolve-activity --brief --user current @intent -p $Package
    if ($LASTEXITCODE -ne 0) { throw "无法解析 $Package 的 Launcher Activity" }
    $pattern = '^{0}/[\w.$]+$' -f [regex]::Escape($Package)
    $component = $resolved | Where-Object { $_ -cmatch $pattern } | Select-Object -First 1
    if (!$component) { throw "无法解析 $Package 的 Launcher Activity。`n$($resolved -join "`n")" }

    Write-Host "启动 $component"
    $result = & $Adb -s $Serial shell am start -W --user current @intent -n "'$component'"
    if ($LASTEXITCODE -ne 0 -or !($result -match '^Status: ok\s*$')) {
        throw "启动失败。`n$($result -join "`n")"
    }
    $result | Write-Output
}

function Get-AppLogFilter($Adb, $Serial, $Package) {
    $helpText = (& $Adb -s $Serial logcat --help) -join "`n"
    if ($LASTEXITCODE -ne 0) { throw '无法查询 logcat 参数' }
    if ($helpText.Contains('--uid=')) {
        $packages = & $Adb -s $Serial shell cmd package list packages -U --user current $Package
        if ($LASTEXITCODE -ne 0) { throw "无法查询 $Package 的应用 UID" }
        foreach ($line in $packages) {
            if ($line -cmatch ('^package:{0}\s+uid:([0-9]+)\s*$' -f [regex]::Escape($Package))) {
                return "--uid=$($Matches[1])"
            }
        }
        throw "找不到 $Package 的应用 UID"
    }

    $appPid = (& $Adb -s $Serial shell pidof -s $Package) -join ''
    if ($LASTEXITCODE -ne 0 -or $appPid -notmatch '^[1-9][0-9]*$') {
        throw "找不到 $Package 的应用进程"
    }
    return "--pid=$appPid"
}

if ($args.Count -ge 1 -and $args[0] -ceq '--version') {
    if ($args.Count -ne 1) { Stop-InvalidArguments '--version 不接受其他参数' }
    Write-Output "ts-and-cmd $version"
    exit 0
}
if ($args.Count -ge 1 -and $args[0] -cin @('-h', '--help')) { Show-Usage; exit 0 }
if ($args.Count -eq 0 -or $args[0] -cnotin @('run', 'build')) { Stop-InvalidArguments '请输入 run 或 build 子命令' }
$command = $args[0]
$taskPrefix = 'assemble'
$firstOption = 1
if ($command -ceq 'build') {
    if ($args[1] -cin @('-h', '--help')) { Show-Usage; exit 0 }
    if ($args[1] -cnotin @('apk', 'appbundle')) { Stop-InvalidArguments '请指定构建目标 apk 或 appbundle' }
    if ($args[1] -ceq 'appbundle') { $taskPrefix = 'bundle' }
    $firstOption = 2
}

$variant = 'release'
$buildType = 'Release'
$requested = ''
for ($index = $firstOption; $index -lt $args.Count; $index++) {
    $argument = $args[$index]
    if ($argument -cin @('-h', '--help')) { Show-Usage; exit 0 }
    if ($argument -ceq '--debug') {
        $variant = 'debug'
        $buildType = 'Debug'
        continue
    }
    if ($command -ceq 'build') { Stop-InvalidArguments "未知参数 $argument" }
    if ($argument -cin @('-d', '--device')) {
        $index++
        if ($index -ge $args.Count -or $args[$index] -like '-*' -or !$args[$index]) {
            Stop-InvalidArguments '请提供 ADB 设备序列号'
        }
        $argument = $args[$index]
    } elseif ($argument -like '-*') {
        Stop-InvalidArguments "未知参数 $argument"
    }
    if ($requested -or !$argument) { Stop-InvalidArguments '请指定一个有效的设备序列号' }
    $requested = $argument
}
$task = ":app:${taskPrefix}$buildType"

try {
    $wrapper = Join-Path (Get-Location).ProviderPath 'gradlew.bat'
    if (!(Test-Path -LiteralPath $wrapper -PathType Leaf)) { throw '请在包含 gradlew.bat 的 Android 工程根目录运行' }
    $sdk = Get-SdkDirectory
    if (!(Test-Path -LiteralPath $sdk -PathType Container)) { throw "找不到 Android SDK（$sdk），请检查 sdk.dir 或 ANDROID_HOME" }
    $sdk = (Get-Item -LiteralPath $sdk).FullName
    if ($command -ceq 'run') {
        $adb = Join-Path $sdk 'platform-tools/adb.exe'
        if (!(Test-Path -LiteralPath $adb -PathType Leaf)) { throw "找不到 adb，请在 $sdk 安装 Android SDK Platform Tools" }
        $serial = Select-Device $adb $requested

        $aapt2 = Get-ChildItem -LiteralPath (Join-Path $sdk 'build-tools') -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            ForEach-Object { Join-Path $_.FullName 'aapt2.exe' } |
            Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
            Select-Object -First 1
        if (!$aapt2) { throw "找不到 aapt2，请在 $sdk 安装 Android SDK Build Tools" }
    }

    $env:ANDROID_HOME = $sdk
    if (Test-Path Env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT = $sdk }
    if (!$env:JAVA_HOME -and !(Get-Command java.exe -CommandType Application -ErrorAction SilentlyContinue)) {
        $studioJdk = Join-Path $env:ProgramFiles 'Android/Android Studio/jbr'
        if (!(Test-Path -LiteralPath (Join-Path $studioJdk 'bin/java.exe') -PathType Leaf)) {
            throw '找不到可用的 JDK，请设置 JAVA_HOME 指向工程所需的 JDK'
        }
        $env:JAVA_HOME = $studioJdk
    }

    if ($command -ceq 'run') { Write-Host "设备 $serial，构建 $task" } else { Write-Host "构建 $task" }
    & $wrapper $task
    if ($LASTEXITCODE -ne 0) { throw "Gradle 构建失败（退出码 $LASTEXITCODE）" }
    if ($command -ceq 'build') { exit 0 }

    $apk = Get-BuiltApk $variant
    $badging = (& $aapt2 dump badging $apk) -join "`n"
    if ($LASTEXITCODE -ne 0 -or $badging -notmatch "(?m)^package: name='([A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z][A-Za-z0-9_]*)+)'") {
        throw "无法从 APK 读取 applicationId（$apk）"
    }
    $package = $Matches[1]
    Write-Host "安装 $package → $serial"
    & $adb -s $serial install -r $apk
    if ($LASTEXITCODE -ne 0) { throw "APK 安装失败（退出码 $LASTEXITCODE）" }
    $logStart = (& $adb -s $serial shell date +%s) -join ''
    if ($LASTEXITCODE -ne 0) { $logStart = '' }
    Start-App $adb $serial $package

    $filter = Get-AppLogFilter $adb $serial $package
    $logStart = if ($logStart -match '^[0-9]+$') { "${logStart}.000" } else { '1' }
} catch {
    [Console]::Error.WriteLine("ts-and-cmd ${command}: $($_.Exception.Message)")
    exit 1
}

$logArgs = @('-s', $serial, 'logcat', '-v', 'threadtime', '-T', $logStart, $filter)
$interactive = ![Console]::IsInputRedirected
$logWidth = if ([Console]::IsOutputRedirected) { 0 } else { [Console]::WindowWidth }
if ($interactive) {
    Write-Host "正在输出 $package 的日志。按 q 退出 App，按 Ctrl+C 仅停止查看。"
} else {
    Write-Host "正在输出 $package 的日志，按 Ctrl+C 停止查看。"
}

$logProcess = $null
$first = $null
$lastKey = $null
$repeat = 0
if ($interactive) { $controlCMode = [Console]::TreatControlCAsInput }
try {
    if ($interactive) { [Console]::TreatControlCAsInput = $true }
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $adb
    $startInfo.Arguments = $logArgs -join ' '
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $logProcess = [System.Diagnostics.Process]::Start($startInfo)
    $pending = $logProcess.StandardOutput.ReadLineAsync()
    while ($true) {
        if ($interactive -and [Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true).KeyChar
            if ($key -eq [char]3) { exit 130 }
            if ($key -ceq 'q') {
                & $adb -s $serial shell am force-stop --user current $package
                if ($LASTEXITCODE -ne 0) { throw "无法退出 $package" }
                exit 0
            }
        }
        if (!$pending.IsCompleted) {
            Start-Sleep -Milliseconds 100
            continue
        }
        $line = $pending.GetAwaiter().GetResult()
        if ($null -eq $line) { break }
        $pending = $logProcess.StandardOutput.ReadLineAsync()
        $logKey = if ($line -cmatch '^\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d+\s+\d+\s+\d+\s+([VDIWEFA]\s+.*)$') { $Matches[1] } else { $null }
        if ($null -eq $logKey -or $logKey -cne $lastKey) {
            if ($null -ne $first) {
                if ($logWidth -gt 1) { [Console]::Write("`r") }
                [Console]::WriteLine("[$repeat] $first")
            }
            $first = $null
            $lastKey = $logKey
            if ($null -eq $logKey) { [Console]::WriteLine($line); continue }
            $first = $line
            $repeat = 0
        }
        $repeat++
        if ($logWidth -gt 1) {
            $preview = "[$repeat] $first"
            $limit = if ($preview -match '[^\x00-\x7f]') { [int][Math]::Floor(($logWidth - 1) / 2) } else { $logWidth - 1 }
            [Console]::Write("`r" + $preview.Substring(0, [Math]::Min($limit, $preview.Length)))
        }
    }
    $logProcess.WaitForExit()
    exit $logProcess.ExitCode
} catch {
    [Console]::Error.WriteLine("ts-and-cmd run: $($_.Exception.Message)")
    exit 1
} finally {
    if ($interactive) { [Console]::TreatControlCAsInput = $controlCMode }
    if ($null -ne $first) {
        if ($logWidth -gt 1) { [Console]::Write("`r") }
        [Console]::WriteLine("[$repeat] $first")
    }
    if ($logProcess) {
        if (!$logProcess.HasExited) { Stop-Process -InputObject $logProcess -ErrorAction SilentlyContinue }
        $logProcess.Dispose()
    }
}
