# Codex 中转站配置

## macOS

打开 macOS 的「终端」，复制并运行：

```bash
/bin/bash <(/usr/bin/curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/main/tb-gpt-setup-mac)
```

## Windows

打开 Windows PowerShell 5.1 或 PowerShell 7，复制并运行：

```powershell
& ([scriptblock]::Create([Text.Encoding]::UTF8.GetString((Invoke-WebRequest -UseBasicParsing -ErrorAction Stop 'https://raw.githubusercontent.com/tbtsfastad/shell/main/tb-gpt-setup-windows.ps1').RawContentStream.ToArray()).TrimStart([char]0xFEFF)))
```

## 安装与恢复

- **安装（输入 `1`）**：在「请输入中转站 API Key」提示后粘贴你的 Key，再按回车。macOS 和 Windows 都会在输入时显示 Key，方便核对。脚本会备份原配置，再写入使用 `gpt-6.1-sol` 的中转站配置。
- **恢复（输入 `9`）**：再次运行同一条命令，即可恢复首次安装前的配置。
- **退出（输入 `0`）**：关闭脚本菜单。

安装或恢复后，请完全退出 Codex 桌面端再重新打开。macOS 上可用 `⌘Q` 退出。

默认在用户主目录的 `.codex` 中写入 `config.toml`，并在 `backup-ccexx` 下保存首次安装前的配置。Windows 上默认使用 `%USERPROFILE%\.codex`。如果设置了 `CODEX_HOME`，则使用指定目录。

脚本源码不包含 API Key。运行时可按提示输入，也可预先设置环境变量 `CODEX_RELAY_API_KEY`。安装后，Codex 从本机的 `config.toml` 读取令牌。
