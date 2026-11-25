# ts-and-cmd

## 安装

每台电脑只需执行一次。安装脚本会下载对应平台的 `ts-and-cmd` 并配置 `PATH`。

### macOS

```sh
curl -fsSL https://raw.githubusercontent.com/tbtsfastad/shell/refs/heads/main/scripts/ts-and-cmd-setup-mac | /bin/bash
```

安装后重新打开终端。

### Windows

在 PowerShell 中执行。

```powershell
& ([scriptblock]::Create((Invoke-RestMethod -ErrorAction Stop 'https://raw.githubusercontent.com/tbtsfastad/shell/main/scripts/ts-and-cmd-setup-windows.ps1')))
```

## 使用

在 Android 工程根目录执行。

```sh
ts-and-cmd run                  # Release，第一台可用设备
ts-and-cmd run xxxx             # Release，指定设备
ts-and-cmd run --debug -d xxxx  # Debug，指定设备
ts-and-cmd run --help           # 查看用法
```

App 启动后会持续输出应用日志。按 `q` 停止日志并退出 App，无需回车。按 `Ctrl+C` 只停止查看日志，App 继续运行。

### 仅构建

在 Android 工程根目录执行。默认构建 Release，加 `--debug` 构建 Debug。构建无需连接设备。

```sh
ts-and-cmd build apk
ts-and-cmd build apk --debug
ts-and-cmd build appbundle
ts-and-cmd build appbundle --debug
```
