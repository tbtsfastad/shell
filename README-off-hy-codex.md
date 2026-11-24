# 腾讯 Hy4 接入 Codex

这套安装脚本基于腾讯 AI Studio 文档中心的 Codex 接入说明，适用于已安装 Codex 的 macOS 和 Windows 用户。开始前，请开通对应服务并获取腾讯云 API Key。[腾讯官方 Codex 接入文档](https://hy-model-ap-prod-1258344703.cos.accelerate.myqcloud.com/public/hy4/docs/zh/k7ou_codex.md)

## macOS

在脚本所在目录打开终端，运行：

```bash
/bin/bash ./off-hy-codex-setup-mac
```

安装后，按 `⌘Q` 完全退出 Codex 桌面端，再重新打开。使用 Codex CLI 时，在启动它的终端执行：

```bash
export HY4_API_KEY="$(launchctl getenv HY4_API_KEY)"
```

脚本通过 `launchctl` 为当前 macOS 登录会话设置 Key。重新登录 macOS 后，请再次运行脚本设置 Key。

## Windows

在脚本所在目录打开 Windows PowerShell 5.1 或 PowerShell 7，运行：

```powershell
& ([scriptblock]::Create((Get-Content -LiteralPath '.\off-hy-codex-setup-windows.ps1' -Raw -Encoding UTF8)))
```

脚本将 `HY4_API_KEY` 设置为当前 Windows 用户的环境变量。安装后请完全退出 Codex 桌面端再打开，或在新的 PowerShell 窗口启动 Codex CLI。

## 安装与恢复

- **输入 `1`** 安装 TokenHub 配置（按量计费）。
- **输入 `2`** 安装 Token Plan 配置（订阅套餐）。
- **输入 `9`** 恢复首次安装前的 `config.toml`。如果安装前没有配置文件，恢复时会移除脚本生成的配置文件。
- **输入 `0`** 退出。

安装时按提示粘贴对应渠道的 API Key，输入内容会显示在终端。脚本会下载并校验腾讯官方 Hy4 模型目录，再写入 Codex 配置。API Key 由 `HY4_API_KEY` 提供。

默认配置目录是用户主目录下的 `.codex`。设置 `CODEX_HOME` 时使用指定目录。原配置备份与 Hy4 模型目录都在 `backup-hy4/` 中。恢复后仍可通过环境变量使用此前设置的 Key。
