#requires -Version 5.1

$ErrorActionPreference = 'Stop'

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw '此脚本仅适用于 Windows。'
}

function Get-SetupItem {
    param([string]$Path, [switch]$Directory)

    try {
        $item = Get-Item -LiteralPath $Path -Force
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        return
    }

    if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
        ($item.PSIsContainer -ne $Directory.IsPresent)) {
        throw "文件或目录类型不符合预期：$Path"
    }
    return $item
}

Write-Host 'Codex 配置管理（Windows）'
Write-Host '1) 配置'
Write-Host '2) 恢复'
Write-Host '3) 退出'
$choice = Read-Host '请选择 [1/2/3]'
switch ($choice) {
    '1' { break }
    '2' { break }
    '3' { return }
    default { throw '请选择 1、2 或 3。' }
}

$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$codexHome = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($codexHome)
$configPath = Join-Path $codexHome 'config.toml'
$backupDir = Join-Path $codexHome 'backup-codex-setup'
$backupConfig = Join-Path $backupDir 'config.toml'
$noConfig = Join-Path $backupDir 'no-config'
$lockPath = Join-Path $codexHome '.codex-setup.windows.lock'
$tempConfig = Join-Path $codexHome ('.codex-config-{0}.tmp' -f [Guid]::NewGuid())
$tempBackup = Join-Path $backupDir ('.original-{0}.tmp' -f [Guid]::NewGuid())

if ($choice -eq '1') {
    Write-Host ''
    Write-Host '请选择服务商'
    Write-Host '1) TB-GPT'
    Write-Host '2) Kimi'
    Write-Host '0) 退出'
    $selection = Read-Host '请选择 [1/2/0]'
    switch ($selection) {
        '1' {
            $selectionName = 'TB-GPT'
        }
        '2' {
            $selectionName = 'Kimi'
        }
        '0' { return }
        default { throw '请选择 1、2 或 0。' }
    }

    [IO.Directory]::CreateDirectory($codexHome) | Out-Null
}
elseif (-not [IO.Directory]::Exists($codexHome)) {
    throw "找不到可用备份：$backupDir"
}

$null = Get-SetupItem $lockPath
$lock = [IO.FileStream]::new(
    $lockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite,
    [IO.FileShare]::None, 4096, [IO.FileOptions]::DeleteOnClose
)
try {
    $configExists = $null -ne (Get-SetupItem $configPath)
    $backupDirExists = $null -ne (Get-SetupItem $backupDir -Directory)
    $hasBackup = $false
    $hadNoConfig = $false
    if ($backupDirExists) {
        $hasBackup = $null -ne (Get-SetupItem $backupConfig)
        $hadNoConfig = $null -ne (Get-SetupItem $noConfig)
    }

    if ($choice -eq '2') {
        if ($hasBackup) {
            [IO.File]::Copy($backupConfig, $tempConfig)
        }
        elseif ($hadNoConfig) {
            if ($configExists) {
                [IO.File]::Delete($configPath)
            }
            Write-Host '已恢复到安装前没有 config.toml 的状态。'
            Write-Host '请完全退出 Codex 桌面端，再重新打开。'
            return
        }
        else {
            throw "找不到可用备份：$backupDir"
        }
    }
    else {
        $backupChoice = '1'
        if ($backupDirExists) {
            Write-Host ''
            if ($hasBackup -or $hadNoConfig) {
                Write-Host "已有备份：$backupDir"
            }
            else {
                Write-Host "备份目录已存在，但没有可用备份：$backupDir"
            }
            Write-Host '1) 用当前配置替换备份'
            Write-Host '2) 忽略，保留现有备份'
            $backupChoice = Read-Host '请选择 [1/2]'
            if ($backupChoice -notin '1', '2') {
                throw '请选择 1 或 2。'
            }
        }

        Write-Host ''
        if ($selection -eq '2') {
            $secureKey = Read-Host '请输入 Kimi API Key' -AsSecureString
            try {
                $token = [PSCredential]::new('Kimi', $secureKey).GetNetworkCredential().Password
            }
            finally {
                $secureKey.Dispose()
            }
        }
        else {
            $token = Read-Host "请输入 $selectionName API Key（输入内容会显示）"
        }
        if ($token -cnotmatch '\A[A-Za-z0-9._~+/-]+=*\z') {
            throw 'API Key 为空或含有无效字符。'
        }

        if ($selection -eq '1') {
            $config = @"
model_provider = "OpenAI"
model = "gpt-6.1-sol"
review_model = "gpt-6.1-sol"
web_search = "live"
disable_response_storage = true
network_access = "enabled"

[model_providers.OpenAI]
name = "OpenAI"
base_url = "https://g.ccexx.com/v1"
model_catalog_url = "https://g.ccexx.com/v1/models"
wire_api = "responses"
requires_openai_auth = false
experimental_bearer_token = "$token"
http_headers = { "x-openai-actor-authorization" = "local-image-extension" }

[features]
api_key_model_discovery = true
image_generation = true
goals = true
"@
        }
        else {
            $config = @'
model = "kimi-k3.1-pro"
model_provider = "kimi"
model_context_window = 1048576

[model_providers.kimi]
name = "Kimi"
base_url = "https://api.moonshot.cn/v1"
env_key = "KIMI_API_KEY"
wire_api = "responses"
'@
        }
        [IO.File]::WriteAllText($tempConfig, $config + [Environment]::NewLine)

        if ($backupChoice -eq '1') {
            [IO.Directory]::CreateDirectory($backupDir) | Out-Null
            if ($configExists) {
                [IO.File]::Copy($configPath, $tempBackup)
                if ($hasBackup) {
                    [IO.File]::Replace($tempBackup, $backupConfig, [NullString]::Value)
                }
                else {
                    [IO.File]::Move($tempBackup, $backupConfig)
                }
                [IO.File]::Delete($noConfig)
            }
            else {
                [IO.File]::WriteAllText($noConfig, '')
                [IO.File]::Delete($backupConfig)
            }
        }

        if ($selection -eq '2') {
            [Environment]::SetEnvironmentVariable('KIMI_API_KEY', $token, 'User')
            $env:KIMI_API_KEY = $token
        }
        $token = $null
    }

    if ($configExists) {
        [IO.File]::Replace($tempConfig, $configPath, [NullString]::Value)
    }
    else {
        [IO.File]::Move($tempConfig, $configPath)
    }

    if ($choice -eq '1') {
        Write-Host "已配置 ${selectionName}：$configPath"
        Write-Host "备份目录：$backupDir"
        [Environment]::SetEnvironmentVariable('HY4_API_KEY', [NullString]::Value, 'User')
        $env:HY4_API_KEY = $null
        if ($selection -eq '1') {
            [Environment]::SetEnvironmentVariable('KIMI_API_KEY', [NullString]::Value, 'User')
            $env:KIMI_API_KEY = $null
        }
    }
    else {
        Write-Host "已恢复配置：$configPath"
    }
    Write-Host '请完全退出 Codex 桌面端，再重新打开。'
}
finally {
    try {
        foreach ($path in $tempConfig, $tempBackup) {
            if ([IO.File]::Exists($path)) {
                [IO.File]::Delete($path)
            }
        }
    }
    finally {
        $lock.Dispose()
    }
}
