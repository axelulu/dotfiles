#!/bin/bash

# 提示用户输入用户名和邮箱
echo "请输入用户名："
read username
echo "请输入邮箱："
read email

# 配置 git 用户信息
git config user.name "$username"
git config user.email "$email"

echo "Git 用户信息已更新：$username <$email>"