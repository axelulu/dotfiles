#!/bin/bash

# 提示用户输入提交信息
echo "请输入提交信息："
read message

# 执行 git commit 命令
git commit -m "$message"