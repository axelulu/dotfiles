#!/usr/bin/env zsh

# Log file path
log_file="/tmp/set_terminal_tab_title.log"

# Check if log file exists
if [ ! -e "$log_file" ]; then
    touch "$log_file"  # Create log file if it doesn't exist
fi

function set_name () {
  echo "Setting terminal tab title..." >> "$log_file"
  local source_dir="${PWD##*/}"
  echo "source_dir: $source_dir" >> "$log_file"
  local current_command=$(ps -o comm= -p $PPID)
  echo "current_command: $current_command" >> "$log_file"
  
  echo "Checking if source_dir starts with a dot..." >> "$log_file"
  if [[ "$source_dir" != .* ]]; then
    echo "Formatting source_dir name" >> "$log_file"
    source_dir=$(echo "$source_dir" | awk -F'[-_]' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')
  fi
  
  echo "Checking if current_command is nvim or vim..." >> "$log_file"
  if [[ "$current_command" == "nvim" || "$current_command" == "vim" ]]; then
    echo "Setting terminal tab title to $current_command $source_dir" >> "$log_file"
    echo -ne "\033]0;${current_command} '|' ${source_dir}\007"
  else
    echo "Setting terminal tab title to $source_dir" >> "$log_file"
    echo -ne "\033]0;${source_dir}\007"
  fi
  echo "Terminal tab title set!" >> "$log_file"
}

# Check if using Zsh or Bash and set the function accordingly
if [ -n "$ZSH_VERSION" ]; then
  precmd_functions+=(set_name)
elif [ -n "$BASH_VERSION" ]; then
  PROMPT_COMMAND='set_name'
fi
