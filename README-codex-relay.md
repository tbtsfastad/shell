# Codex 配置与恢复

## macOS

打开 macOS 的「终端」，复制并运行：

```bash
/bin/bash <(/usr/bin/curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/main/codex-setup-mac)
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
| `2` | 腾讯 Hy4 · TokenHub（按量计费） |
| `3` | 腾讯 Hy4 · Token Plan（订阅套餐） |
| `4` | Kimi |

备份目录已存在时，脚本会在询问 API Key 前提示：

- **输入 `1` 替换**：用本次配置前的状态覆盖原备份。
- **输入 `2` 忽略**：保留现有备份，继续配置。

首次配置会自动备份。主菜单输入 `2` 可恢复保留的备份。如果备份记录的是没有配置文件的状态，恢复时会移除脚本生成的配置文件。主菜单输入 `3` 退出，服务商菜单输入 `0` 退出。

安装或恢复后，请完全退出 Codex 桌面端再重新打开。macOS 上可用 `⌘Q` 退出。

配置和备份默认保存在用户主目录的 `.codex` 中。设置了 `CODEX_HOME` 时使用指定目录。统一脚本的备份在 `backup-codex-setup/` 下。

脚本在配置时读取 API Key。TB-GPT 的 Key 写入本机配置，HY 和 Kimi 的 Key 由环境变量提供。恢复仅还原配置文件。如果恢复后的配置使用了此前的 HY 或 Kimi Key，需要确认对应环境变量仍是原来的 Key。

在 macOS 上使用 HY 或 Kimi 的 Codex CLI，请先执行脚本末尾显示的 `export` 命令。重新登录 macOS 后，需重新设置相应的 Key。Windows 上可在新的 PowerShell 窗口启动 Codex CLI。
