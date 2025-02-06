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

function sync_cursor_settings() {
  local cursor_settings=~/Library/Application\ Support/cursor/User/settings.json
  local cursor_keybindings=~/Library/Application\ Support/cursor/User/keybindings.json

  local cursor_bak_settings=~/Dotfiles/cursor/.config/cursor.bak/settings.json
  local cursor_bak_keybindings=~/Dotfiles/cursor/.config/cursor.bak/keybindings.json

  # Ensure the backup files exist
  if [ -f $cursor_bak_settings ] && [ -f $cursor_bak_keybindings ]; then

    # Check if the source files exist
    if [ ! -f $cursor_settings ]; then
      # If the source settings.json does not exist, create it from the backup
      cp $cursor_bak_settings $cursor_settings
      echo "Created $cursor_settings from backup."
    fi

    if [ ! -f $cursor_keybindings ]; then
      # If the source keybindings.json does not exist, create it from the backup
      cp $cursor_bak_keybindings $cursor_keybindings
      echo "Created $cursor_keybindings from backup."
    fi

    # Get modification times if both source and backup files exist
    if [ -f $cursor_settings ] && [ -f $cursor_keybindings ]; then
      local cursor_settings_mod=$(stat -f "%m" $cursor_settings)
      local cursor_keybindings_mod=$(stat -f "%m" $cursor_keybindings)
      local cursor_bak_settings_mod=$(stat -f "%m" $cursor_bak_settings)
      local cursor_bak_keybindings_mod=$(stat -f "%m" $cursor_bak_keybindings)

      # Function to handle diff and prompt
      function handle_diff_and_prompt() {
        local source_file=$1
        local backup_file=$2
        local source_mod=$3
        local backup_mod=$4
        local file_type=$5

        # Check for actual content differences
        if diff $backup_file $source_file &> /dev/null; then
          echo "$file_type is in sync."
        else
          echo "Differences detected in $file_type:"

          # Determine which tool to use for diff output
          if command -v diff-so-fancy &> /dev/null; then
            diff $backup_file $source_file | diff-so-fancy
          elif command -v bat &> /dev/null; then
            diff $backup_file $source_file | bat --paging=always --color=always --language=diff
          else
            diff $backup_file $source_file | cat
          fi

          if [ $source_mod -gt $backup_mod ]; then
            echo "The local $file_type is newer. Do you want to update the backup? (y/n)"
          else
            echo "The backup $file_type is newer. Do you want to update the local file? (y/n)"
          fi

          read -r response
          if [[ $response == "y" ]]; then
            if [ $source_mod -gt $backup_mod ]; then
              cp $source_file $backup_file
              echo "Backup of $file_type updated."
            else
              cp $backup_file $source_file
              echo "Local $file_type updated from backup."
            fi
          else
            echo "No changes made to $file_type."
          fi
        fi
      }

      # Check and prompt for settings.json
      handle_diff_and_prompt $cursor_settings $cursor_bak_settings $cursor_settings_mod $cursor_bak_settings_mod "settings.json"

      # Check and prompt for keybindings.json
      handle_diff_and_prompt $cursor_keybindings $cursor_bak_keybindings $cursor_keybindings_mod $cursor_bak_keybindings_mod "keybindings.json"
    fi
  else
    echo "Backup files do not exist. Please ensure backup files are available."
  fi
}