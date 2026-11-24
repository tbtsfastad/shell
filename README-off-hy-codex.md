# 腾讯 Hy4 接入 Codex

## macOS

打开 macOS 的「终端」，复制并运行：

```bash
/bin/bash <(/usr/bin/curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/main/off-hy-codex-setup-mac)
```

## Windows

打开 Windows PowerShell 5.1 或 PowerShell 7，复制并运行：

```powershell
& ([scriptblock]::Create([Text.Encoding]::UTF8.GetString((Invoke-WebRequest -UseBasicParsing -ErrorAction Stop 'https://raw.githubusercontent.com/tbtsfastad/shell/main/off-hy-codex-setup-windows.ps1').RawContentStream.ToArray()).TrimStart([char]0xFEFF)))
```

## 安装与恢复

- **安装（输入 `1` 或 `2`）**：`1` 为 TokenHub（按量计费），`2` 为 Token Plan（订阅套餐）。按提示粘贴对应渠道的腾讯云 API Key，再按回车。输入内容会显示在终端。
- **恢复（输入 `9`）**：再次运行同一条命令，即可恢复首次安装前的配置。
- **退出（输入 `0`）**：关闭脚本菜单。

安装或恢复后，请完全退出 Codex 桌面端再重新打开。macOS 上可用 `⌘Q` 退出。

安装时会下载并校验腾讯官方 Hy4 模型目录。默认配置目录是用户主目录下的 `.codex`。设置 `CODEX_HOME` 时使用指定目录。原配置与模型目录都保存在 `backup-hy4/`。Codex 通过环境变量 `HY4_API_KEY` 读取密钥，该变量在恢复配置后仍可使用。

## 使用 Codex CLI

macOS 脚本通过 `launchctl` 为当前登录会话设置 Key。在启动 Codex CLI 的终端执行以下命令。重新登录 macOS 后，请再次运行安装命令设置 Key。

```bash
export HY4_API_KEY="$(launchctl getenv HY4_API_KEY)"
```

Windows 脚本将 Key 设置为当前用户的环境变量。安装后可打开新的 PowerShell 窗口启动 Codex CLI。[腾讯官方 Codex 接入文档](https://hy-model-ap-prod-1258344703.cos.accelerate.myqcloud.com/public/hy4/docs/zh/k7ou_codex.md)
