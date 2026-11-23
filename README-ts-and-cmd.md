# ts-and-cmd（macOS）

## 安装

首次安装，在终端复制执行一次。

```sh
( ts_tmp="$(mktemp)" && trap 'rm -f "$ts_tmp"' EXIT &&
  curl -fsSL 'https://raw.githubusercontent.com/tbtsfastad/shell/main/ts-and-cmd' -o "$ts_tmp" &&
  python3 "$ts_tmp" install ) && export PATH="$HOME/.local/bin:$PATH"
```

## 使用

在 Android 工程根目录执行。

```sh
ts-and-cmd run                  # Release，第一台可用设备
ts-and-cmd run xxxx             # Release，指定设备
ts-and-cmd run --debug -d xxxx  # Debug，指定设备
ts-and-cmd run --help           # 查看用法
```
