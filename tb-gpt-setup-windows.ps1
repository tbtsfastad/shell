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

Write-Host 'Codex 中转站配置（Windows · gpt-6.1-sol）'
Write-Host '1) 安装配置'
Write-Host '9) 恢复安装前的配置'
Write-Host '0) 退出'
$choice = Read-Host '请选择 [1/9/0]'
switch ($choice) {
    '0' { return }
    '1' { break }
    '9' { break }
    default { throw '请选择 1、9 或 0。' }
}

$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$codexHome = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($codexHome)
$configPath = Join-Path $codexHome 'config.toml'
$backupDir = Join-Path $codexHome 'backup-ccexx'
$backupConfig = Join-Path $backupDir 'config.toml'
$noConfig = Join-Path $backupDir 'no-config'
$lockPath = Join-Path $codexHome '.ccexx-setup.windows.lock'
$tempConfig = Join-Path $codexHome ('.ccexx-config-{0}.tmp' -f [Guid]::NewGuid())
$tempBackup = Join-Path $backupDir ('.original-{0}.tmp' -f [Guid]::NewGuid())

if ($choice -eq '1') {
    Write-Host ''
    $token = Read-Host '请输入中转站 API Key（输入内容会显示）'
    if ($token -cnotmatch '\A[A-Za-z0-9._~+/-]+=*\z') {
        throw 'API Key 为空或含有无效字符。'
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
        if ($hasBackup -and $hadNoConfig) {
            throw "备份状态冲突：$backupDir"
        }
    }

    if ($choice -eq '9') {
        if ($hadNoConfig) {
            if ($configExists) {
                [IO.File]::Delete($configPath)
            }
            Write-Host '已恢复到安装前没有 config.toml 的状态。'
            Write-Host '请完全退出 Codex 桌面端，再重新打开。'
            return
        }
        if (-not $hasBackup) {
            throw "找不到可用备份：$backupDir"
        }
        [IO.File]::Copy($backupConfig, $tempConfig)
    }
    else {
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
        [IO.File]::WriteAllText($tempConfig, $config + [Environment]::NewLine)
        $config = $token = $null

        if (-not ($hasBackup -or $hadNoConfig)) {
            [IO.Directory]::CreateDirectory($backupDir) | Out-Null
            if ($configExists) {
                [IO.File]::Copy($configPath, $tempBackup)
                [IO.File]::Move($tempBackup, $backupConfig)
            }
            else {
                [IO.File]::WriteAllText($noConfig, '')
            }
        }
    }

    if ($configExists) {
        [IO.File]::Replace($tempConfig, $configPath, [NullString]::Value)
    }
    else {
        [IO.File]::Move($tempConfig, $configPath)
    }

    if ($choice -eq '1') {
        Write-Host "已写入配置：$configPath"
        Write-Host "首次安装前的配置备份：$backupDir"
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
