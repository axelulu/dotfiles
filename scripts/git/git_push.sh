#!/bin/bash

# 确认是否推送
echo "确定要推送到远程仓库吗？(y/n)"
read confirmation

if [ "$confirmation" == "y" ]; then
  git push
  echo "代码已推送到远程仓库。"
else
  echo "推送已取消。"
fi