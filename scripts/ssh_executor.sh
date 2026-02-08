#!/bin/bash
# 接收文件路径作为参数
file_path="$1"

# 执行您需要的SSH操作
# 例如：将文件上传到远程服务器
kitten transfer --direction=upload $file_path ./

# 或者执行其他SSH相关操作
# ssh user@remote_server "command_to_execute_with_file $file_path"

echo "已处理文件: $file_path"
