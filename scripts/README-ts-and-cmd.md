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

### 运行 App

```sh
ts-and-cmd run
ts-and-cmd run --debug -d xxxx
```

| 参数 | 作用 | 省略时 |
| --- | --- | --- |
| `--debug` | 构建并运行 Debug 版本 | Release |
| `-d <序列号>` | 指定 ADB 设备 | `adb devices` 列出的第一台可用设备 |
| `-h`、`--help` | 显示用法 | 正常执行命令 |

#### 日志操作

App 启动后会持续输出应用日志。

| 输入 | 操作方式 | 作用 |
| --- | --- | --- |
| `q` | 直接按键 | 停止日志并退出 App |
| `Ctrl+C` | 直接按键 | 停止查看日志，App 继续运行 |
| `f -w "关键词"` | 输入后回车 | 隐藏后续包含该关键词的日志，可多次添加 |
| `f -c` | 输入后回车 | 清除所有关键词过滤 |

### 仅构建

构建无需连接设备。构建成功后会列出产物的绝对路径。

```sh
ts-and-cmd build apk
ts-and-cmd build apk --debug
ts-and-cmd build appbundle
ts-and-cmd build appbundle --debug
```

| 参数 | 作用 | 省略时 |
| --- | --- | --- |
| `apk` / `appbundle` | 选择构建 APK 或 AAB | 必选其一 |
| `--debug` | 构建 Debug 版本 | Release |
| `-h`、`--help` | 显示用法 | 正常执行命令 |
