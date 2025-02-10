#!/usr/bin/env zsh
# Description: This script is used to setup the workspaces and apps for work mode

# Get open apps
open_apps=$(osascript ~/.config/scripts/scpts/all_running_app.scpt)
# separate the open_apps string by comma into an array
open_apps=(${(s:, :)open_apps})

# Safe apps with space indices
typeset -A work_apps
work_apps=(
  ["Finder"]=1
  ["WezTerm"]=1
  ["Visual Studio Code"]=2
  ["Google Chrome"]=3
  ["Lark"]=4
  ["Spotify"]=5
  ["WeChat"]=6
)

# Close all apps that are not in the safe apps list
for app in $open_apps; do
  if [[ -z ${work_apps[$app]} ]]; then
    echo "Closing $app"
    osascript -e 'quit app "'"$app"'"'
  fi
done

# Open apps that are not open
for app space_index in "${(@kv)work_apps}"; do
  if [[ ! $open_apps[(r)$app] ]]; then
    echo "Opening $app"
    # 如果是 VS Code 则执行额外命令
    if [[ "$app" == "Visual Studio Code" ]]; then
        # 先执行code命令再打开应用
        code ~/Dev/ButterflyEffect/monica
    else
        # 普通应用直接打开
        open -a "$app"
    fi
    sleep 1 && (
      SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n ${SPACES[$space_index]} ]] && yabai -m window --space ${SPACES[$space_index]}
    )
  fi
done
