#!/bin/bash

# 设置错误处理
set -e
trap 'echo "发生错误，脚本退出"; exit 1' ERR

# 检查是否是 Arch Linux
is_arch_linux() {
  if [ -f /etc/arch-release ]; then
    return 0  # 是 Arch Linux
  elif [ -f /etc/os-release ] && grep -q "ID=arch" /etc/os-release; then
    return 0  # 是 Arch Linux
  fi
  return 1  # 不是 Arch Linux
}

# 检查是否以 root 权限运行
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "错误: 此脚本需要 root 权限运行。"
    echo "请使用 sudo 或以 root 用户身份运行此脚本。"
    exit 1
  fi
}

# 检查必要的工具是否已安装
check_dependencies() {
  for cmd in pacman dialog; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "错误: 未找到 $cmd 命令。"
      echo "请安装必要的依赖: sudo pacman -S $cmd"
      exit 1
    fi
  done
}

# 设置 dialog 颜色为黑色背景 - 修复语法
setup_dialog_colors() {
  # 创建临时配置文件
  local temp_rc=$(mktemp)
  
  # 配置黑色背景 - 修复语法
  cat > "$temp_rc" << EOF
use_shadow = OFF
use_colors = ON
screen_color = (BLACK,BLACK,OFF)
dialog_color = (WHITE,BLACK,OFF)
title_color = (WHITE,BLACK,OFF)
border_color = (WHITE,BLACK,OFF)
button_active_color = (BLACK,WHITE,ON)
button_inactive_color = (WHITE,BLACK,OFF)
button_key_active_color = (BLACK,WHITE,ON)
button_key_inactive_color = (WHITE,BLACK,OFF)
button_label_active_color = (BLACK,WHITE,ON)
button_label_inactive_color = (WHITE,BLACK,OFF)
inputbox_color = (WHITE,BLACK,OFF)
inputbox_border_color = (WHITE,BLACK,OFF)
searchbox_color = (WHITE,BLACK,OFF)
searchbox_title_color = (WHITE,BLACK,OFF)
searchbox_border_color = (WHITE,BLACK,OFF)
position_indicator_color = (WHITE,BLACK,OFF)
menubox_color = (WHITE,BLACK,OFF)
menubox_border_color = (WHITE,BLACK,OFF)
item_color = (WHITE,BLACK,OFF)
item_selected_color = (BLACK,WHITE,ON)
tag_color = (WHITE,BLACK,OFF)
tag_selected_color = (BLACK,WHITE,ON)
tag_key_color = (WHITE,BLACK,OFF)
tag_key_selected_color = (BLACK,WHITE,ON)
check_color = (WHITE,BLACK,OFF)
check_selected_color = (BLACK,WHITE,ON)
uarrow_color = (WHITE,BLACK,OFF)
darrow_color = (WHITE,BLACK,OFF)
EOF
  
  # 设置 DIALOGRC 环境变量
  export DIALOGRC="$temp_rc"
  
  # 测试 dialog 配置是否有效
  if ! dialog --print-maxsize 2>/dev/null; then
    echo "警告: dialog 配置可能有问题，将使用默认配置。"
    unset DIALOGRC
  fi
}

# 获取已安装的软件包列表 - 优化版本
get_installed_packages() {
  # 使用临时文件存储结果
  local temp_file=$(mktemp)
  
  # 获取已安装的软件包列表，限制数量以加快速度
  # 默认显示前100个软件包
  pacman -Qq | head -n 100 | sort > "$temp_file"
  
  # 返回结果
  cat "$temp_file"
  rm -f "$temp_file"
}

# 显示软件包详细信息
show_package_info() {
  local pkg="$1"
  
  clear
  echo "正在获取 $pkg 的详细信息..."
  echo "----------------------------------------"
  echo "软件包: $pkg"
  echo "----------------------------------------"
  
  # 显示软件包详细信息
  pacman -Qi "$pkg" 2>/dev/null || echo "无法获取软件包信息"
  
  echo "----------------------------------------"
  echo "依赖关系:"
  echo "----------------------------------------"
  
  # 显示依赖关系
  pacman -Qc "$pkg" 2>/dev/null || echo "无法获取依赖关系"
  
  echo "----------------------------------------"
  echo "文件列表 (前20个):"
  echo "----------------------------------------"
  
  # 显示软件包包含的文件
  pacman -Ql "$pkg" 2>/dev/null | head -n 20 || echo "无法获取文件列表"
  if [ "$(pacman -Ql "$pkg" 2>/dev/null | wc -l)" -gt 20 ]; then
    echo "... (更多文件未显示)"
  fi
  
  echo "----------------------------------------"
  
  read -p "按 Enter 键继续..."
}

# 删除软件包及其所有相关内容
remove_package() {
  local pkg="$1"
  
  clear
  echo "正在删除 $pkg 及其所有相关内容..."
  
  # 使用 pacman -Rns 删除软件包及其所有依赖和配置文件
  if pacman -Rns "$pkg" --noconfirm; then
    echo "已成功删除 $pkg 及其所有相关内容。"
  else
    echo "删除 $pkg 时出错。"
  fi
  
  read -p "按 Enter 键继续..."
}

# 主菜单
main_menu() {
  local packages=()
  local choices=()
  
  # 显示加载消息
  clear
  echo "正在加载已安装的软件包列表，请稍候..."
  
  # 获取已安装的软件包列表
  mapfile -t packages < <(get_installed_packages)
  
  if [ ${#packages[@]} -eq 0 ]; then
    dialog --title "错误" --msgbox "无法获取已安装的软件包列表。\n请检查 pacman 是否正常工作。" 8 50
    exit 1
  fi
  
  while true; do
    # 创建对话框选项
    choices=()
    for pkg in "${packages[@]}"; do
      desc=$(pacman -Qi "$pkg" 2>/dev/null | grep "Description" | cut -d ":" -f 2- | sed 's/^[ \t]*//' | head -c 50)
      [ -z "$desc" ] && desc="无描述"
      choices+=("$pkg" "$desc")
    done
    
    # 显示对话框
    cmd=(dialog --backtitle "Arch Linux 软件包管理器" \
          --title "已安装的软件包" \
          --menu "选择一个软件包查看详情或删除 (已安装 ${#packages[@]} 个软件包)" \
          22 76 16)
    
    # 添加搜索选项和退出选项
    choices+=("SEARCH" "搜索软件包")
    choices+=("EXIT" "退出脚本")
    
    selection=$("${cmd[@]}" "${choices[@]}" 2>&1 >/dev/tty)
    
    # 处理选择
    if [ -z "$selection" ] || [ "$selection" = "EXIT" ]; then
      clear
      echo "感谢使用 Arch Linux 软件包管理器！"
      # 删除临时配置文件
      [ -n "$DIALOGRC" ] && rm -f "$DIALOGRC"
      break
    elif [ "$selection" = "SEARCH" ]; then
      # 搜索功能
      search_term=$(dialog --backtitle "Arch Linux 软件包管理器" \
                    --title "搜索软件包" \
                    --inputbox "输入搜索关键词:" \
                    8 60 \
                    2>&1 >/dev/tty)
      
      if [ -n "$search_term" ]; then
        # 搜索匹配的软件包
        search_results=()
        for pkg in "${packages[@]}"; do
          if [[ "$pkg" == *"$search_term"* ]]; then
            search_results+=("$pkg")
          fi
        done
        
        if [ ${#search_results[@]} -eq 0 ]; then
          dialog --backtitle "Arch Linux 软件包管理器" \
                 --title "搜索结果" \
                 --msgbox "没有找到匹配 '$search_term' 的软件包。" \
                 8 60
        else
          # 更新包列表为搜索结果
          packages=("${search_results[@]}")
        fi
      fi
    else
      # 显示软件包操作菜单
      action=$(dialog --backtitle "Arch Linux 软件包管理器" \
               --title "软件包: $selection" \
               --menu "选择操作:" \
               12 60 3 \
               "INFO" "查看软件包详细信息" \
               "REMOVE" "删除软件包及其所有相关内容" \
               "BACK" "返回软件包列表" \
               2>&1 >/dev/tty)
      
      case "$action" in
        INFO)
          show_package_info "$selection"
          ;;
        REMOVE)
          if dialog --backtitle "Arch Linux 软件包管理器" \
                   --title "确认删除" \
                   --yesno "你确定要删除 $selection 及其所有相关内容吗？\n\n这将删除软件包、其依赖和配置文件。" \
                   10 60; then
            remove_package "$selection"
            # 更新软件包列表
            mapfile -t packages < <(get_installed_packages)
          fi
          ;;
        BACK|"")
          # 返回主菜单
          ;;
      esac
    fi
  done
}

# 主函数
main() {
  clear
  echo "Arch Linux 软件包管理器"
  echo "========================"
  
  # 检查是否是 Arch Linux
  if ! is_arch_linux; then
    echo "错误: 此脚本只能在 Arch Linux 系统上运行。"
    exit 1
  fi
  
  # 检查 root 权限
  check_root
  
  # 检查依赖
  check_dependencies
  
  # 设置 dialog 颜色为黑色背景
  setup_dialog_colors
  
  # 显示主菜单
  main_menu
}

# 运行主函数
main

