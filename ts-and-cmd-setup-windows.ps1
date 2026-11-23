$ErrorActionPreference = 'Stop'
$commandUrl = 'https://raw.githubusercontent.com/tbtsfastad/shell/main/ts-and-cmd-windows.ps1'
# Update the checksum in the same commit as changes to ts-and-cmd-windows.ps1.
$commandSha256 = '6469909b78b004eda21a0cd613c1350d2e06e715b56bb718b8f846411e94ffbf'

function Add-CommandDirectory([string]$PathValue, [string]$Directory) {
    $entries = @($PathValue -split ';' | Where-Object {
        $_ -and $_.Trim('"').TrimEnd([char[]]'\/') -ine $Directory
    })
    return (@($Directory) + $entries) -join ';'
}

if (!$env:LOCALAPPDATA) { throw '找不到当前用户的 LOCALAPPDATA 目录' }
$bin = Join-Path $env:LOCALAPPDATA 'Programs/ts-and-cmd/bin'
$null = New-Item -ItemType Directory -Path $bin -Force
$staging = New-Item -ItemType Directory -Path (Join-Path $bin ([Guid]::NewGuid().ToString('N')))

try {
    $scriptName = 'ts-and-cmd-windows.ps1'
    $script = Join-Path $staging.FullName $scriptName
    & curl.exe -fsSL $commandUrl -o $script
    if ($LASTEXITCODE -ne 0) { throw "下载 ts-and-cmd 失败（curl 退出码 $LASTEXITCODE）" }
    if ((Get-FileHash -LiteralPath $script -Algorithm SHA256).Hash -ine $commandSha256) {
        throw 'ts-and-cmd 下载文件的校验值不匹配，请重新运行安装命令'
    }

    $launcher = Join-Path $staging.FullName 'ts-and-cmd.cmd'
    @'
@echo off
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "%~dp0ts-and-cmd-windows.ps1" %*
exit /b %ERRORLEVEL%
'@ | Set-Content -LiteralPath $launcher -Encoding Ascii
    Move-Item -LiteralPath $script -Destination (Join-Path $bin $scriptName) -Force
    Move-Item -LiteralPath $launcher -Destination (Join-Path $bin 'ts-and-cmd.cmd') -Force

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $installedPath = Add-CommandDirectory $userPath $bin
    if ($userPath -cne $installedPath) { [Environment]::SetEnvironmentVariable('Path', $installedPath, 'User') }
    $env:Path = Add-CommandDirectory $env:Path $bin
    Write-Host "已安装 $(Join-Path $bin 'ts-and-cmd.cmd') 并配置用户 PATH"
} finally {
    Remove-Item -LiteralPath $staging.FullName -Recurse -Force
}
