# Kimi 接入 Codex

这套安装脚本按 Kimi 开放平台的 Codex 接入说明配置 `kimi-k3.1-pro`，供已安装 Codex 的 macOS 和 Windows 用户使用。运行前，请在 Kimi 开放平台创建 API Key。[创建 API Key](https://platform.kimi.com/console/api-keys) · [Kimi 官方 Codex 接入文档](https://platform.kimi.com/docs/guide/codex-kimi)

## macOS

在脚本所在目录打开终端，运行：

```bash
/bin/bash ./off-kimi-codex-setup-mac
```

安装后，按 `⌘Q` 完全退出 Codex 桌面端，再重新打开。使用 Codex CLI 时，在启动它的终端执行：

```bash
export KIMI_API_KEY="$(launchctl getenv KIMI_API_KEY)"
```

脚本通过 `launchctl` 为当前 macOS 登录会话设置 Key。重新登录 macOS 后，请再次运行脚本设置 Key。

## Windows

在脚本所在目录打开 Windows PowerShell 5.1 或 PowerShell 7，运行：

```powershell
& ([scriptblock]::Create((Get-Content -LiteralPath '.\off-kimi-codex-setup-windows.ps1' -Raw -Encoding UTF8)))
```

脚本将 `KIMI_API_KEY` 设置为当前 Windows 用户的环境变量。安装后请完全退出 Codex 桌面端再打开，或在新的 PowerShell 窗口启动 Codex CLI。

## 安装与恢复

- **输入 `1`** 安装。按提示粘贴 Kimi API Key，输入内容不会回显。
- **输入 `9`** 恢复首次安装前的 `config.toml`。如果安装前没有配置文件，脚本会移除自己生成的配置。
- **输入 `0`** 退出。

默认配置目录是用户主目录下的 `.codex`。设置 `CODEX_HOME` 时使用指定目录。原配置保存在 `backup-kimi/` 中。Codex 通过环境变量 `KIMI_API_KEY` 读取密钥，该变量在恢复配置后仍可使用。
