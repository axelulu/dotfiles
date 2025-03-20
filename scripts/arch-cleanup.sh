#!/bin/bash
#
# 增强版 Arch Linux 系统清理脚本
# 用途：全面清理系统中的缓存和临时文件
# 版本：2.2 (修复语法错误)
#

# 配置选项（可根据需要调整）
LOG_FILE="/var/log/arch-cleanup-$(date +%Y-%m-%d).log"
KEEP_PACKAGE_VERSIONS=2      # 保留的软件包版本数
LOG_RETENTION_SIZE="500M"    # 日志保留大小
LOG_RETENTION_TIME="4weeks"  # 日志保留时间
TEMP_FILE_AGE=10             # 临时文件保留天数
BROWSER_CACHE_CLEAN=true     # 是否清理浏览器缓存
DEEP_CLEAN=true              # 是否执行深度清理

# 如果不是 Arch Linux，打印错误信息并退出
if ! is_arch_linux; then
  echo "错误: 此脚本只能在 Arch Linux 系统上运行。" >&2
  exit 1
fi

# 输出彩色信息的函数
print_info() {
    echo -e "\e[1;34m[信息]\e[0m $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "\e[1;32m[成功]\e[0m $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "\e[1;33m[警告]\e[0m $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "\e[1;31m[错误]\e[0m $1" | tee -a "$LOG_FILE"
}

print_section() {
    echo -e "\e[1;36m\n===== $1 =====\e[0m" | tee -a "$LOG_FILE"
}

# 检查命令是否存在
check_command() {
    command -v "$1" &> /dev/null
}

# 安全删除函数（带错误处理）
safe_remove() {
    if [ -e "$1" ]; then
        rm -rf "$1" 2>> "$LOG_FILE" && print_success "已删除: $1" || print_error "删除失败: $1"
    fi
}

# 检查是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
    print_error "此脚本需要 root 权限运行"
    exit 1
fi

# 创建日志文件目录（如果不存在）
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

# 记录脚本开始执行
echo "=======================================================" > "$LOG_FILE"
echo "Arch Linux 系统清理脚本 - 执行时间: $(date)" >> "$LOG_FILE"
echo "=======================================================" >> "$LOG_FILE"

# 记录开始时间和初始磁盘使用情况
start_time=$(date +%s)
initial_usage=$(df -h / | awk 'NR==2 {print $5}')
initial_free=$(df -h / | awk 'NR==2 {print $4}')
total_space=$(df -h / | awk 'NR==2 {print $2}')

print_info "开始系统清理，磁盘总空间: $total_space，初始使用率: $initial_usage (可用: $initial_free)"
echo "=======================================================" | tee -a "$LOG_FILE"

# 1. 清理 pacman 缓存
print_section "清理软件包缓存"

# 检查并安装 pacman-contrib（如果需要）
if ! check_command paccache; then
    print_warning "未找到 paccache，尝试安装 pacman-contrib 包..."
    pacman -S --noconfirm pacman-contrib >> "$LOG_FILE" 2>&1 && print_success "已安装 pacman-contrib" || print_error "安装 pacman-contrib 失败"
fi

# 使用 paccache 清理
if check_command paccache; then
    print_info "清理 pacman 缓存，保留最近 $KEEP_PACKAGE_VERSIONS 个版本..."
    paccache -r -k $KEEP_PACKAGE_VERSIONS >> "$LOG_FILE" 2>&1 && print_success "已清理旧版本软件包"
    paccache -ruk0 >> "$LOG_FILE" 2>&1 && print_success "已清理未安装的软件包"
else
    print_warning "未找到 paccache，使用备选方案..."
    pacman -Sc --noconfirm >> "$LOG_FILE" 2>&1 && print_success "已清理未安装的软件包缓存"
fi

# 显示缓存大小
cache_size=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
print_info "当前软件包缓存大小: $cache_size"

# 2. 清理孤立包（Orphans）
print_section "清理孤立包"
print_info "检查孤立包..."
orphans=$(pacman -Qtdq 2>/dev/null)
if [ -n "$orphans" ]; then
    orphan_count=$(echo "$orphans" | wc -l)
    print_info "发现 $orphan_count 个孤立包，正在删除..."
    echo "$orphans" | pacman -Rns --noconfirm - >> "$LOG_FILE" 2>&1 && print_success "已删除所有孤立包" || print_warning "删除某些孤立包时出错"
else
    print_success "没有发现孤立包"
fi

# 3. 清理日志文件
print_section "清理系统日志"
print_info "清理系统日志，保留大小: $LOG_RETENTION_SIZE，保留时间: $LOG_RETENTION_TIME"
journalctl --vacuum-size=$LOG_RETENTION_SIZE >> "$LOG_FILE" 2>&1
journalctl --vacuum-time=$LOG_RETENTION_TIME >> "$LOG_FILE" 2>&1
print_success "系统日志已清理"

# 检查并清理其他日志文件
log_dir_size_before=$(du -sh /var/log 2>/dev/null | cut -f1)
print_info "清理旧的日志文件，当前日志目录大小: $log_dir_size_before"
find /var/log -type f -name "*.old" -delete
find /var/log -type f -name "*.gz" -delete
find /var/log -type f -regex ".*\.[0-9]+$" -delete
find /var/log -type f -mtime +30 -size +1M -delete
log_dir_size_after=$(du -sh /var/log 2>/dev/null | cut -f1)
print_success "日志清理完成，清理后日志目录大小: $log_dir_size_after"

# 4. 清理 AUR 缓存
print_section "清理 AUR 缓存"
print_info "清理 AUR 助手缓存..."

# 查找所有用户的主目录
user_homes=$(find /home -maxdepth 1 -type d -not -path "/home")

# 清理 yay 缓存
for home in $user_homes; do
    username=$(basename "$home")
    if [ -d "$home/.cache/yay" ]; then
        cache_size_before=$(du -sh "$home/.cache/yay" 2>/dev/null | cut -f1)
        print_info "清理用户 $username 的 yay 缓存，当前大小: $cache_size_before"
        find "$home/.cache/yay" -type d -name "*.tar.gz" -delete 2>/dev/null
        find "$home/.cache/yay" -type f -name "PKGBUILD" -delete 2>/dev/null
        rm -rf "$home/.cache/yay/"* 2>/dev/null
        cache_size_after=$(du -sh "$home/.cache/yay" 2>/dev/null | cut -f1)
        print_success "已清理用户 $username 的 yay 缓存，清理后大小: $cache_size_after"
    fi
done

# 清理 paru 缓存
for home in $user_homes; do
    username=$(basename "$home")
    if [ -d "$home/.cache/paru" ]; then
        cache_size_before=$(du -sh "$home/.cache/paru" 2>/dev/null | cut -f1)
        print_info "清理用户 $username 的 paru 缓存，当前大小: $cache_size_before"
        rm -rf "$home/.cache/paru/clone/"* 2>/dev/null
        cache_size_after=$(du -sh "$home/.cache/paru" 2>/dev/null | cut -f1)
        print_success "已清理用户 $username 的 paru 缓存，清理后大小: $cache_size_after"
    fi
done

# 5. 清理 systemd 失败的单元
print_section "清理 systemd"
print_info "重置 systemd 失败的单元..."
systemctl reset-failed >> "$LOG_FILE" 2>&1
print_success "systemd 失败的单元已重置"

# 清理旧的 systemd 日志
print_info "清理旧的 systemd 日志..."
journalctl --rotate >> "$LOG_FILE" 2>&1
print_success "systemd 日志已轮转"

# 6. 清理临时文件
print_section "清理临时文件"
print_info "清理 $TEMP_FILE_AGE 天前的临时文件..."

# 清理 /tmp
tmp_size_before=$(du -sh /tmp 2>/dev/null | cut -f1)
print_info "清理 /tmp 目录，当前大小: $tmp_size_before"
find /tmp -type f -atime +$TEMP_FILE_AGE -delete 2>/dev/null
find /tmp -type d -empty -delete 2>/dev/null
tmp_size_after=$(du -sh /tmp 2>/dev/null | cut -f1)
print_success "/tmp 目录已清理，清理后大小: $tmp_size_after"

# 清理 /var/tmp
var_tmp_size_before=$(du -sh /var/tmp 2>/dev/null | cut -f1)
print_info "清理 /var/tmp 目录，当前大小: $var_tmp_size_before"
find /var/tmp -type f -atime +$TEMP_FILE_AGE -delete 2>/dev/null
find /var/tmp -type d -empty -delete 2>/dev/null
var_tmp_size_after=$(du -sh /var/tmp 2>/dev/null | cut -f1)
print_success "/var/tmp 目录已清理，清理后大小: $var_tmp_size_after"

# 7. 清理用户缓存
print_section "清理用户缓存"

# 清理缩略图缓存
print_info "清理缩略图缓存..."
for home in $user_homes; do
    username=$(basename "$home")
    # 清理 .thumbnails
    if [ -d "$home/.thumbnails" ]; then
        thumb_size=$(du -sh "$home/.thumbnails" 2>/dev/null | cut -f1)
        print_info "清理用户 $username 的缩略图缓存 (.thumbnails)，大小: $thumb_size"
        rm -rf "$home/.thumbnails/"* 2>/dev/null
        print_success "已清理用户 $username 的 .thumbnails 目录"
    fi
    
    # 清理 .cache/thumbnails
    if [ -d "$home/.cache/thumbnails" ]; then
        cache_thumb_size=$(du -sh "$home/.cache/thumbnails" 2>/dev/null | cut -f1)
        print_info "清理用户 $username 的缩略图缓存 (.cache/thumbnails)，大小: $cache_thumb_size"
        rm -rf "$home/.cache/thumbnails/"* 2>/dev/null
        print_success "已清理用户 $username 的 .cache/thumbnails 目录"
    fi
done

# 清理浏览器缓存（如果启用）
if [ "$BROWSER_CACHE_CLEAN" = true ]; then
    print_info "清理浏览器缓存..."
    for home in $user_homes; do
        username=$(basename "$home")
        
        # Firefox
        if [ -d "$home/.cache/mozilla/firefox" ]; then
            ff_cache_size=$(du -sh "$home/.cache/mozilla/firefox" 2>/dev/null | cut -f1)
            print_info "清理用户 $username 的 Firefox 缓存，大小: $ff_cache_size"
            find "$home/.cache/mozilla/firefox" -type d -name "cache2" -exec rm -rf {}/* \; 2>/dev/null
            print_success "已清理用户 $username 的 Firefox 缓存"
        fi
        
        # Chrome
        if [ -d "$home/.cache/google-chrome" ]; then
            chrome_cache_size=$(du -sh "$home/.cache/google-chrome" 2>/dev/null | cut -f1)
            print_info "清理用户 $username 的 Chrome 缓存，大小: $chrome_cache_size"
            find "$home/.cache/google-chrome" -type d -name "Cache" -exec rm -rf {}/* \; 2>/dev/null
            print_success "已清理用户 $username 的 Chrome 缓存"
        fi
        
        # Chromium
        if [ -d "$home/.cache/chromium" ]; then
            chromium_cache_size=$(du -sh "$home/.cache/chromium" 2>/dev/null | cut -f1)
            print_info "清理用户 $username 的 Chromium 缓存，大小: $chromium_cache_size"
            find "$home/.cache/chromium" -type d -name "Cache" -exec rm -rf {}/* \; 2>/dev/null
            print_success "已清理用户 $username 的 Chromium 缓存"
        fi
    done
fi

# 8. 运行 updatedb 更新文件数据库
print_section "更新文件数据库"
if check_command updatedb; then
    print_info "更新文件数据库 (updatedb)..."
    updatedb >> "$LOG_FILE" 2>&1
    print_success "文件数据库已更新"
else
    print_warning "未找到 updatedb 命令，跳过文件数据库更新"
fi

# 9. 清理 flatpak（如果已安装）
if check_command flatpak; then
    print_section "清理 Flatpak"
    print_info "清理 Flatpak 未使用的运行时..."
    flatpak_before=$(flatpak list --runtime | wc -l)
    flatpak uninstall --unused --assumeyes >> "$LOG_FILE" 2>&1
    flatpak_after=$(flatpak list --runtime | wc -l)
    removed=$((flatpak_before - flatpak_after))
    print_success "已清理 $removed 个未使用的 Flatpak 运行时"
    
    print_info "清理 Flatpak 缓存..."
    flatpak repair --verbose >> "$LOG_FILE" 2>&1
    print_success "Flatpak 缓存已清理"
fi

# 10. 清理 Docker（如果已安装）
if check_command docker; then
    print_section "清理 Docker"
    print_info "检查 Docker 状态..."
    if systemctl is-active --quiet docker; then
        print_info "清理未使用的 Docker 资源..."
        docker_before=$(docker system df 2>/dev/null)
        docker system prune -f >> "$LOG_FILE" 2>&1
        print_success "已清理未使用的 Docker 镜像、容器和网络"
        
        if [ "$DEEP_CLEAN" = true ]; then
            print_info "执行 Docker 深度清理（包括未使用的卷）..."
            docker system prune -f --volumes >> "$LOG_FILE" 2>&1
            print_success "已执行 Docker 深度清理"
        fi
        
        docker_after=$(docker system df 2>/dev/null)
        echo -e "\n清理前 Docker 使用情况:\n$docker_before\n\n清理后 Docker 使用情况:\n$docker_after" >> "$LOG_FILE"
    else
        print_warning "Docker 服务未运行，跳过清理"
    fi
fi

# 11. 清理 npm 缓存（如果已安装）
if check_command npm; then
    print_section "清理 npm 缓存"
    print_info "清理 npm 缓存..."
    npm cache clean --force >> "$LOG_FILE" 2>&1
    print_success "npm 缓存已清理"
fi

# 12. 清理 yarn 缓存（如果已安装）
if check_command yarn; then
    print_section "清理 yarn 缓存"
    print_info "清理 yarn 缓存..."
    yarn cache clean >> "$LOG_FILE" 2>&1
    print_success "yarn 缓存已清理"
fi

# 13. 清理 pip 缓存（如果已安装）
if check_command pip; then
    print_section "清理 pip 缓存"
    print_info "清理 pip 缓存..."
    pip cache purge >> "$LOG_FILE" 2>&1
    print_success "pip 缓存已清理"
fi

# 14. 清理 Go 模块缓存（如果已安装）
if check_command go; then
    print_section "清理 Go 缓存"
    print_info "清理 Go 模块缓存..."
    go clean -cache -modcache -testcache >> "$LOG_FILE" 2>&1
    print_success "Go 缓存已清理"
fi

# 15. 清理 Rust 缓存（如果已安装）
if check_command rustup; then
    print_section "清理 Rust 缓存"
    print_info "清理 Rust 缓存..."
    for home in $user_homes; do
        if [ -d "$home/.cargo" ]; then
            username=$(basename "$home")
            cargo_cache_size=$(du -sh "$home/.cargo/registry/cache" 2>/dev/null | cut -f1)
            print_info "清理用户 $username 的 Rust 缓存，大小: $cargo_cache_size"
            find "$home/.cargo/registry/cache" -type f -name "*.crate" -delete 2>/dev/null
            print_success "已清理用户 $username 的 Rust 缓存"
        fi
    done
fi

# 16. 清理旧的内核（保留当前内核和一个备用内核）
print_section "清理旧内核"
print_info "检查已安装的内核..."
current_kernel=$(uname -r | sed 's/\-arch.*$//')
installed_kernels=$(pacman -Q | grep "^linux " | cut -d' ' -f1)

if [ "$(echo "$installed_kernels" | wc -l)" -gt 2 ]; then
    print_info "发现多个内核，但此操作风险较高，请手动检查并清理"
    echo "当前运行的内核: $current_kernel" | tee -a "$LOG_FILE"
    echo "已安装的内核:" | tee -a "$LOG_FILE"
    pacman -Q | grep "^linux " | tee -a "$LOG_FILE"
else
    print_info "已安装内核数量不超过 2 个，无需清理"
fi

# 17. 清理 fontconfig 缓存
print_section "清理字体缓存"
if check_command fc-cache; then
    print_info "重建字体缓存..."
    fc-cache -f >> "$LOG_FILE" 2>&1
    print_success "字体缓存已重建"
fi

# 18. 清理 ~/.cache 目录中的大文件
print_section "清理用户缓存目录"
print_info "查找并清理用户缓存目录中的大文件（>50MB 且超过 30 天未访问）..."

for home in $user_homes; do
    username=$(basename "$home")
    if [ -d "$home/.cache" ]; then
        cache_size_before=$(du -sh "$home/.cache" 2>/dev/null | cut -f1)
        print_info "检查用户 $username 的缓存目录，当前大小: $cache_size_before"
        
        # 查找大于 50MB 且 30 天未访问的文件
        large_old_files=$(find "$home/.cache" -type f -size +50M -atime +30 2>/dev/null)
        if [ -n "$large_old_files" ]; then
            file_count=$(echo "$large_old_files" | wc -l)
            print_info "发现 $file_count 个大文件，正在清理..."
            echo "$large_old_files" | while read -r file; do
                rm -f "$file" 2>/dev/null
            done
            cache_size_after=$(du -sh "$home/.cache" 2>/dev/null | cut -f1)
            print_success "已清理用户 $username 的缓存目录中的大文件，清理后大小: $cache_size_after"
        else
            print_success "用户 $username 的缓存目录中没有发现需要清理的大文件"
        fi
    fi
done

# 19. 清理下载目录中的临时文件
if [ "$DEEP_CLEAN" = true ]; then
    print_section "清理下载目录临时文件"
    print_info "查找下载目录中的临时文件（.tmp, .temp, .part, .crdownload）..."
    
    for home in $user_homes; do
        username=$(basename "$home")
        if [ -d "$home/Downloads" ]; then
            temp_files=$(find "$home/Downloads" -type f \( -name "*.tmp" -o -name "*.temp" -o -name "*.part" -o -name "*.crdownload" \) -atime +7 2>/dev/null)
            if [ -n "$temp_files" ]; then
                file_count=$(echo "$temp_files" | wc -l)
                print_info "在用户 $username 的下载目录中发现 $file_count 个临时文件，正在清理..."
                echo "$temp_files" | while read -r file; do
                    rm -f "$file" 2>/dev/null
                done
                print_success "已清理用户 $username 下载目录中的临时文件"
            else
                print_success "用户 $username 的下载目录中没有发现需要清理的临时文件"
            fi
        fi
    done
fi

# 20. 清理旧的备份文件
print_section "清理备份文件"
print_info "查找系统中的备份文件（.bak, .old, .orig, ~）..."

# 查找 /etc 中的备份文件
etc_backups=$(find /etc -type f \( -name "*.bak" -o -name "*.old" -o -name "*.orig" -o -name "*~" \) 2>/dev/null)
if [ -n "$etc_backups" ]; then
    file_count=$(echo "$etc_backups" | wc -l)
    print_info "在 /etc 中发现 $file_count 个备份文件"
    echo "$etc_backups" >> "$LOG_FILE"
    print_warning "备份文件可能包含重要配置，请手动检查并清理"
fi

# 21. 清理 systemd 用户单元缓存
print_section "清理 systemd 用户单元缓存"
for home in $user_homes; do
    username=$(basename "$home")
    if [ -d "$home/.config/systemd/user" ]; then
        print_info "重新加载用户 $username 的 systemd 单元..."
        sudo -u "$username" systemctl --user daemon-reload >> "$LOG_FILE" 2>&1
        print_success "已重新加载用户 $username 的 systemd 单元"
    fi
done

# 22. 运行 pacman -Fy 更新文件数据库
print_section "更新 pacman 文件数据库"
print_info "更新 pacman 文件数据库..."
pacman -Fy >> "$LOG_FILE" 2>&1
print_success "pacman 文件数据库已更新"

# 23. 检查并修复 pacman 数据库
print_section "检查 pacman 数据库"
print_info "检查 pacman 数据库..."
pacman -Dk >> "$LOG_FILE" 2>&1 && print_success "pacman 数据库检查完成" || print_warning "pacman 数据库可能存在问题，请运行 'pacman -Dk' 检查详情"

# 24. 清理 systemd 日志（按服务）- 修复版
print_section "清理特定服务的 systemd 日志"
print_info "清理大型服务日志..."

# 直接清理特定服务的日志，不进行大小检查
print_info "清理特定服务的日志..."
for service in NetworkManager.service systemd-journald.service cups.service sddm.service; do
    journalctl --vacuum-time=1week --unit="$service" >> "$LOG_FILE" 2>&1
done
print_success "已清理特定服务的日志"

# 计算节省的空间
end_time=$(date +%s)
final_usage=$(df -h / | awk 'NR==2 {print $5}')
final_free=$(df -h / | awk 'NR==2 {print $4}')

# 尝试计算节省的空间（使用 awk 替代 bc）
initial_free_num=$(echo "$initial_free" | sed 's/G//')
final_free_num=$(echo "$final_free" | sed 's/G//')

# 使用简单的字符串比较
if [[ "$initial_free_num" != "$final_free_num" ]]; then
    # 避免使用浮点数计算，只显示前后变化
    print_success "清理前可用空间: ${initial_free}，清理后可用空间: ${final_free}"
else
    print_info "清理完成，但未检测到明显的空间变化"
fi

echo "=======================================================" | tee -a "$LOG_FILE"
print_info "清理完成！"
echo "运行时间: $(( end_time - start_time )) 秒" | tee -a "$LOG_FILE"
echo "初始磁盘使用率: $initial_usage (可用: $initial_free)" | tee -a "$LOG_FILE"
echo "最终磁盘使用率: $final_usage (可用: $final_free)" | tee -a "$LOG_FILE"
echo "清理完成时间: $(date)" | tee -a "$LOG_FILE"
echo "详细日志已保存至: $LOG_FILE" | tee -a "$LOG_FILE"

# 发送通知（如果在 X 环境中）
if [ -n "$DISPLAY" ] && check_command notify-send; then
    notify-send "系统清理完成" "清理前: $initial_usage\n清理后: $final_usage\n详细日志: $LOG_FILE" -i system-cleanup
fi

exit 0

