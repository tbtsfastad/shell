# Codex 配置与恢复

## macOS

打开 macOS 的「终端」，复制并运行：

```bash
eval "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/main/codex-setup-mac)"
```

## Windows

打开 Windows PowerShell 5.1 或 PowerShell 7，复制并运行：

```powershell
& ([scriptblock]::Create([Text.Encoding]::UTF8.GetString((Invoke-WebRequest -UseBasicParsing -ErrorAction Stop 'https://raw.githubusercontent.com/tbtsfastad/shell/main/codex-setup-windows.ps1').RawContentStream.ToArray()).TrimStart([char]0xFEFF)))
```
