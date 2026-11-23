# ts-and-cmd

## 安装

每台电脑只需执行一次。安装脚本会下载对应平台的 `ts-and-cmd` 并配置 `PATH`。

### macOS

```sh
( ts_setup="$(curl -fsSL 'https://raw.githubusercontent.com/tbtsfastad/shell/main/ts-and-cmd-setup-mac')" &&
  /bin/bash -c "$ts_setup" ) && export PATH="$HOME/.local/bin:$PATH"
```

### Windows

在 PowerShell 中执行。

```powershell
$tsSetup = [IO.Path]::GetTempFileName()
try {
    curl.exe -fsSL 'https://raw.githubusercontent.com/tbtsfastad/shell/main/ts-and-cmd-setup-windows.ps1' -o $tsSetup
    if ($LASTEXITCODE -ne 0) { throw '下载安装脚本失败' }
    & ([scriptblock]::Create([IO.File]::ReadAllText($tsSetup)))
} finally {
    Remove-Item -LiteralPath $tsSetup -Force
}
```

## 使用

在 Android 工程根目录执行。

```sh
ts-and-cmd run                  # Release，第一台可用设备
ts-and-cmd run xxxx             # Release，指定设备
ts-and-cmd run --debug -d xxxx  # Debug，指定设备
ts-and-cmd run --help           # 查看用法
```
