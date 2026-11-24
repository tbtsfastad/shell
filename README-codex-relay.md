# Codex 配置与恢复

## macOS

打开 macOS 的「终端」，复制并运行：

```bash
case "$(/bin/bash <(/usr/bin/curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/main/codex-setup-mac) --report-selection)" in
  1) unset HY4_API_KEY KIMI_API_KEY ;;
  2) unset HY4_API_KEY; export KIMI_API_KEY="$(/bin/launchctl getenv KIMI_API_KEY)" ;;
esac
```

## Windows

打开 Windows PowerShell 5.1 或 PowerShell 7，复制并运行：

```powershell
& ([scriptblock]::Create([Text.Encoding]::UTF8.GetString((Invoke-WebRequest -UseBasicParsing -ErrorAction Stop 'https://raw.githubusercontent.com/tbtsfastad/shell/main/codex-setup-windows.ps1').RawContentStream.ToArray()).TrimStart([char]0xFEFF)))
```

## 配置与恢复

主菜单输入 `1` 配置，接着选择服务商。

| 数字 | 服务商 |
| --- | --- |
| `1` | TB-GPT |
| `2` | Kimi |

备份目录已存在时，脚本会在询问 API Key 前提示：

- **输入 `1` 替换**：用本次配置前的状态覆盖原备份。
- **输入 `2` 忽略**：保留现有备份，继续配置。

首次配置会自动备份。主菜单输入 `2` 可恢复保留的备份。如果备份记录的是没有配置文件的状态，恢复时会移除脚本生成的配置文件。主菜单输入 `3` 退出，服务商菜单输入 `0` 退出。

安装或恢复后，请完全退出 Codex 桌面端再重新打开。macOS 上可用 `⌘Q` 退出。

配置和备份默认保存在用户主目录的 `.codex` 中。设置了 `CODEX_HOME` 时使用指定目录。统一脚本的备份在 `backup-codex-setup/` 下。

配置成功后会清理旧的 `HY4_API_KEY`。切换到 TB-GPT 时，也会清理 `KIMI_API_KEY` 并将 TB-GPT 的 Key 写入本机配置。切换到 Kimi 时，会将 `KIMI_API_KEY` 更新为本次输入的 Key。

macOS 命令同时更新当前终端和登录会话变量。Windows 脚本更新当前 PowerShell 和用户环境变量。其他已打开的终端仍持有各自的变量，Shell 启动文件里的 `export` 也会在新终端重新执行。

恢复只还原配置文件。如果恢复后的配置依赖已清理的环境变量，需要重新设置对应的 Key。
