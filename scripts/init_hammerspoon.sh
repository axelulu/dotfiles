#!/bin/bash

# 目标路径
TARGET_PATH="$HOME/.hammerspoon/init.lua"
# 源文件路径
SOURCE_PATH="$HOME/.config/hammerspoon/init.lua"

# 检查目标路径是否存在并且是符号链接
if [ ! -L "$TARGET_PATH" ]; then
    # 如果文件存在且不是符号链接，删除文件
    if [ -e "$TARGET_PATH" ]; then
        rm "$TARGET_PATH"
    fi
    # 创建符号链接
    ln -s "$SOURCE_PATH" "$TARGET_PATH"
    hsreload
fi
