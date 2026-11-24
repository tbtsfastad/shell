# Kimi 接入 Codex

## macOS

打开 macOS 的「终端」，复制并运行：

```bash
/bin/bash <(/usr/bin/curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/main/off-kimi-codex-setup-mac)
```

## Windows

打开 Windows PowerShell 5.1 或 PowerShell 7，复制并运行：

```powershell
& ([scriptblock]::Create([Text.Encoding]::UTF8.GetString((Invoke-WebRequest -UseBasicParsing -ErrorAction Stop 'https://raw.githubusercontent.com/tbtsfastad/shell/main/off-kimi-codex-setup-windows.ps1').RawContentStream.ToArray()).TrimStart([char]0xFEFF)))
```

## 安装与恢复

- **安装（输入 `1`）**：按提示粘贴 Kimi API Key，再按回车。脚本会备份原配置，输入的 Key 会隐藏。[创建 API Key](https://platform.kimi.com/console/api-keys)
- **恢复（输入 `9`）**：再次运行同一条命令，即可恢复首次安装前的配置。
- **退出（输入 `0`）**：关闭脚本菜单。

安装或恢复后，请完全退出 Codex 桌面端再重新打开。macOS 上可用 `⌘Q` 退出。

默认配置目录是用户主目录下的 `.codex`。设置 `CODEX_HOME` 时使用指定目录。原配置保存在 `backup-kimi/` 中。Codex 通过环境变量 `KIMI_API_KEY` 读取密钥，该变量在恢复配置后仍可使用。

## 使用 Codex CLI

macOS 脚本通过 `launchctl` 为当前登录会话设置 Key。在启动 Codex CLI 的终端执行以下命令。重新登录 macOS 后，请再次运行安装命令设置 Key。

```bash
export KIMI_API_KEY="$(launchctl getenv KIMI_API_KEY)"
```

Windows 脚本将 Key 设置为当前用户的环境变量。安装后可打开新的 PowerShell 窗口启动 Codex CLI。[Kimi 官方 Codex 接入文档](https://platform.kimi.com/docs/guide/codex-kimi)
