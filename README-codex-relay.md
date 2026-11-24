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

- **安装（输入 `1`）**：在「请输入中转站 API Key」提示后粘贴你的 Key，再按回车。macOS 和 Windows 都会在输入时显示 Key，方便核对。脚本会备份原配置。
- **恢复（输入 `9`）**：再次运行同一条命令，即可恢复首次安装前的配置。
- **退出（输入 `0`）**：关闭脚本菜单。

安装或恢复后，请完全退出 Codex 桌面端再重新打开。macOS 上可用 `⌘Q` 退出。

默认在用户主目录的 `.codex` 中写入 `config.toml`，并在 `backup-ccexx` 下保存首次安装前的配置。Windows 上默认使用 `%USERPROFILE%\.codex`。如果设置了 `CODEX_HOME`，则使用指定目录。

脚本源码不包含 API Key。安装后，Codex 从本机的 `config.toml` 读取令牌。

## 腾讯 Hy4

先在腾讯云开通对应服务并获取 API Key。菜单里的 `1` 使用 TokenHub（按量计费），`2` 使用 Token Plan（订阅套餐）。请粘贴与所选渠道对应的 Key。[腾讯官方 Codex 接入文档](https://hy-model-ap-prod-1258344703.cos.accelerate.myqcloud.com/public/hy4/docs/zh/k7ou_codex.md)

### macOS

```bash
/bin/bash <(/usr/bin/curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/main/tb-hy-codex-setup-mac)
```

脚本用 `launchctl` 为当前登录会话设置 `HY4_API_KEY`。安装后按 `⌘Q` 退出桌面端，再重新打开。已打开的终端在启动 Codex CLI 前，运行：

```bash
export HY4_API_KEY="$(launchctl getenv HY4_API_KEY)"
```

重新登录 macOS 后，请重新运行安装脚本设置 Key。

### Windows

打开 Windows PowerShell 5.1 或 PowerShell 7，复制运行：

```powershell
& ([scriptblock]::Create([Text.Encoding]::UTF8.GetString((Invoke-WebRequest -UseBasicParsing -ErrorAction Stop 'https://raw.githubusercontent.com/tbtsfastad/shell/main/tb-hy-codex-setup-windows.ps1').RawContentStream.ToArray()).TrimStart([char]0xFEFF)))
```

脚本会将 `HY4_API_KEY` 设置为当前 Windows 用户的环境变量。完全退出 Codex 后重新打开，或打开新的 PowerShell 窗口启动 CLI。

### 备份与恢复

安装时会验证腾讯官方 Hy4 模型目录，并保存到 Codex 目录下的 `backup-hy4/models.json`。首次安装前的 `config.toml` 备份也在 `backup-hy4` 中。再次运行对应命令，选 `9` 可恢复首次安装前的配置。恢复后，已设置的 `HY4_API_KEY` 仍可供其他 Hy4 配置使用。
