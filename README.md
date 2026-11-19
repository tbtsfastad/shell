# Codex 中转站配置（macOS）

打开 macOS 的「终端」，复制并运行：

```bash
/bin/bash <(/usr/bin/curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/main/tb-gpt-setup-mac)
```

- **安装（输入 `1`）**：按提示输入中转站 API Key，输入时不会回显。脚本会备份原配置，再写入使用 `gpt-6.1-sol` 的中转站配置。
- **恢复（输入 `9`）**：再次运行同一条命令，即可恢复首次安装前的配置。
- **退出（输入 `0`）**：关闭脚本菜单。

安装或恢复后，如果你正在使用 Codex 桌面端，请按 `⌘Q` 完全退出应用，再重新打开。

默认配置文件是 `~/.codex/config.toml`，备份目录是 `~/.codex/backup-ccexx/`。如果设置了 `CODEX_HOME`，脚本会在该目录下读写相同的文件和备份目录。API Key 只在安装时写入本机配置文件，该文件的权限为 `600`。
