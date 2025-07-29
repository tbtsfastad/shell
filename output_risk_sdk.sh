#!/bin/bash
#对风控sdk插件进行重命名：https://github.com/tbtsfastad/bo_risk
change_name() {
    local NEW_NAME="$1"
    local FILE_SETTINGS="android/settings.gradle"
    sed -i.bak "s/^rootProject\.name = .*/rootProject\.name = \"$NEW_NAME\"/" "$FILE_SETTINGS"
    rm "${FILE_SETTINGS}.bak"
    local FILE="pubspec.yaml"
    sed -i.bak "s/^name:.*/name: $NEW_NAME/" "$FILE"
    rm "${FILE}.bak"
    local FILE_READ_ME="README.md"
    sed -i.bak "s/bo_risk/$NEW_NAME/" "$FILE_READ_ME"
    rm "${FILE_READ_ME}.bak"
}

change_package() {
    local NEW_PACKAGE_NAME="$1"
    local FILE="android/build.gradle"
    sed -i.bak "s/^group = .*/group = \"$NEW_PACKAGE_NAME\"/" "$FILE"
    sed -i.bak "s/namespace = .*/namespace = \"$NEW_PACKAGE_NAME\"/" "$FILE"
    rm "${FILE}.bak"
    local FILE_MANIFEST="android/src/main/AndroidManifest.xml"
    sed -i.bak "s/package=\".*\"/package=\"$NEW_PACKAGE_NAME\"/" "$FILE_MANIFEST"
    rm "${FILE_MANIFEST}.bak"
    local FILE_PUBSPEC="pubspec.yaml"
    sed -i.bak "s/package: .*/package: $NEW_PACKAGE_NAME/" "$FILE_PUBSPEC"
    rm "${FILE_PUBSPEC}.bak"
    local PLUGIN_PROJECT_ROOT="$(pwd)"
    local FILE_SRC="android/src/main/java"
    local NEW_SRC="${NEW_PACKAGE_NAME//.//}"
    local OLD_SRC="com/example/bo_risk"
    cd $FILE_SRC
    mkdir -p $NEW_SRC
    mv "$PLUGIN_PROJECT_ROOT/$FILE_SRC/$OLD_SRC"/*.java "$PLUGIN_PROJECT_ROOT/$FILE_SRC/$NEW_SRC/"
    rmdir -p $OLD_SRC
    for item in "$PLUGIN_PROJECT_ROOT/$FILE_SRC/$NEW_SRC"/*; do
        sed -i.bak "s/^package .*;/package $NEW_PACKAGE_NAME;/" "$item"
        rm "${item}.bak"
    done
    cd $PLUGIN_PROJECT_ROOT
}

# 设置颜色以增强输出可读性
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}### Flutter 插件重命名脚本启动 ###${NC}"
echo -e "${YELLOW}警告: 开始前请务必备份你的项目！${NC}"
echo ""

# 检查 pubspec.yaml 文件是否存在，以确认在正确的目录下
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}错误: 未在当前目录找到 'pubspec.yaml' 文件。${NC}"
    echo -e "${RED}请将此脚本放置在 Flutter 插件的根目录下再运行。${NC}"
    exit 1
fi

# 获取用户输入
echo "--> 请输入新的插件名"

# 获取新的插件名 (用于 pubspec.yaml)
read -p "请输入新的插件名 (例如: my_awesome_plugin): " NEW_PLUGIN_NAME

if [ -z "$NEW_PLUGIN_NAME" ]; then
    echo -e "${RED}错误: 插件名不能为空。${NC}"
    exit 1
fi

# 获取新的源码路径
read -p "请输入新的源码路径 (例如: com.company.awesomeplugin): " NEW_BUNDLE_ID

if [ -z "$NEW_BUNDLE_ID" ]; then
    echo -e "${RED}错误: 新的源码路径不能为空。${NC}"
    exit 1
fi
echo ""

# 执行重命名命令
echo "--> =准备执行重命名操作..."
echo "    新插件名: ${NEW_PLUGIN_NAME}"
echo "    新包名 (Bundle ID): ${NEW_BUNDLE_ID}"
echo ""

read -p "确认以上信息并开始重命名吗? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "操作已取消。"
    exit 0
fi

echo "正在重命名请稍候..."
rm -rf "example"
change_name "$NEW_PLUGIN_NAME"
change_package "$NEW_BUNDLE_ID"

echo "重命名完成"


exit 0

