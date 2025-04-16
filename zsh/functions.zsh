# FZF Navigation

function nnn () {
    command nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
    fi
}

function suyabai () {
  SHA256=$(shasum -a 256 /opt/homebrew/bin/yabai | awk "{print \$1;}")
  if [ -f "/private/etc/sudoers.d/yabai" ]; then
    sudo sed -i '' -e 's/sha256:[[:alnum:]]*/sha256:'${SHA256}'/' /private/etc/sudoers.d/yabai
  else
    echo "sudoers file does not exist yet"
  fi
}

function ya() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	# rm -f -- "$tmp"
}

# Api call helper
function api() {
  if [ "$1" = "get" ]; then
    curl -s "$2" | jless
  elif [ "$1" = "post" ]; then
    curl -s -X POST -d '{}' "$2" | jless
  else
    echo "Invalid operation. Use 'get' or 'post'."
  fi
}

rm_confirm() {
    local confirm
        # If not, proceed with the standard confirmation
        echo -n "Are you sure you wanna run 'rm -rf'? (yes/no): "
        read confirm
        if [ "$confirm" = "yes" ]; then
            command rm  "$@"
        else
            echo "Operation canceled."
        fi
}

# Override git commit with a custom function
git_custom() {
  if [[ $1 == "commit" ]]; then
    sh ~/.config/scripts/git_commit.sh
  elif [[ $1 == "user" ]]; then  # Corrected the syntax here
    sh ~/.config/scripts/git_user.sh
  elif [[ $1 == "push" ]]; then
    sh ~/.config/scripts/git_push.sh
        # Call the original git command for other cases
    command git "$@"

  else
    # Call the original git command for other cases
    command git "$@"
  fi
}

# Function to search directories from the root
fcd() {
  local dir
  #Store the current directory
  local original_dir=$(pwd)
  #Change to the home directory
  cd ~ || return
  #Run fd and fzf from the home directory
  dir=$(fd --type d --exclude .git | fzf --preview 'tree -C -L 3 {}' --preview-window '~3') && cd "$dir"
  #If a directory is selected, change to it; otherwise, return to the original directory
  if [ -n "$dir" ]; then
    cd "$dir"
  else
    cd "$original_dir"
  fi
}


# Precmd function to move the prompt to the bottom
function precmd() {
  # echo -ne "\033[999;1H"
}

# Function to add a new alias
function add_alias() {
  if [ -z "$1" ]; then
    echo "Enter alias name: "
    read alias_name
  fi
  echo "Enter alias command: "
  read alias_command
  echo "alias $alias_name='$alias_command'" >> ~/.config/zsh/aliases.zsh
  # Reload the aliases
  source ~/.config/zsh/.zshrc
  # check if the alias was added
  if grep -q "alias $alias_name=" ~/.config/zsh/aliases.zsh; then
    echo "Alias $alias_name added."
  else
    echo "Alias $alias_name not added."
  fi
}

# Function to remove an  existing alias
function remove_alias() {
  if [ -z "$1" ]; then
    echo "Enter alias name: "
    read alias_name
  fi
  # does the alias exist?
  if grep -q "alias $alias_name=" ~/.config/zsh/aliases.zsh; then
    sed -i '' "/alias $alias_name=/d" ~/.config/zsh/aliases.zsh
    # Reload the aliases
    source ~/.config/zsh/.zshrc
    # confirm alias removed
    echo "Alias $alias_name removed."
  else
    echo "Alias $alias_name not found."
  fi
}

# 新增：更新别名名称（保留原命令）
function update_alias_name() {
  if [ -z "$1" ]; then
    echo "Enter OLD alias name: "
    read old_name
  else
    old_name=$1
  fi

  # 检查旧别名是否存在
  if ! grep -q "alias $old_name=" ~/.config/zsh/aliases.zsh; then
    echo "Alias $old_name does not exist."
    return 1
  fi

  echo "Enter NEW alias name: "
  read new_name
  if [ -z "$new_name" ]; then
    echo "New name cannot be empty!"
    return 1
  fi

  # 使用精确匹配替换旧别名名称
  sed -i '' "s/alias $old_name=/alias $new_name=/" ~/.config/zsh/aliases.zsh

  # 重新加载并验证
  source ~/.config/zsh/.zshrc
  if grep -q "alias $new_name=" ~/.config/zsh/aliases.zsh; then
    echo "Alias renamed: $old_name → $new_name"
  else
    echo "Failed to rename alias"
  fi
}

# 新增：更新别名命令（保留名称）
function update_alias_command() {
  if [ -z "$1" ]; then
    echo "Enter alias name: "
    read name
  else
    name=$1
  fi

  # 检查别名是否存在
  if ! grep -q "alias $name=" ~/.config/zsh/aliases.zsh; then
    echo "Alias $name does not exist."
    return 1
  fi

  echo "Enter NEW command: "
  read new_cmd
  if [ -z "$new_cmd" ]; then
    echo "Command cannot be empty!"
    return 1
  fi

  # 使用定界符保留原别名名称
  sed -i '' "s/\(alias $name='\).*\('\)/\1${new_cmd//'/\\'}\2/" ~/.config/zsh/aliases.zsh

  # 重新加载并验证
  source ~/.config/zsh/.zshrc
  if grep -q "alias $name='$new_cmd'" ~/.config/zsh/aliases.zsh; then
    echo "Command updated for $name"
  else
    echo "Failed to update command"
  fi
}

# 获取当前 Git 分支名称
git_branch_name() {
  # 尝试使用 git symbolic-ref 获取分支名称（对于正常分支）
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  # 如果上面的命令失败（例如在分离头指针状态下），则使用 git rev-parse 获取
  if [ -z "$branch" ]; then
    branch=$(git rev-parse --short HEAD 2>/dev/null)
    # 添加前缀，表明这是一个分离的 HEAD
    if [ -n "$branch" ]; then
      branch="detached-${branch}"
    else
      # 如果仍然失败，可能不在 git 仓库中
      branch="not-a-git-repo"
    fi
  fi

  echo "$branch"
}

# SSH 函数，自动修改标题并在结束后恢复
kssh() {
    # 提取 IP 地址
    ip=$(echo "$*" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
    command kitty +kitten ssh "$@"
}

ssh_drag() {
  echo "请将文件拖入终端..."
  read file_path
  ~/.config/scripts/ssh_executor.sh "$file_path"
}
