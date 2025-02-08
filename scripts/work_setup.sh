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
  ["Visual Studio Code"]=1
  ["Google Chrome"]=2
  ["Lark"]=2
  ["Spotify"]=3
  ["WeChat"]=3
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
    open -a "$app" && sleep 1 && (
      SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n ${SPACES[$space_index]} ]] && yabai -m window --space ${SPACES[$space_index]}
    )
  fi
done

SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[1] ]] && yabai -m space --focus $SPACES[1]
yabai -m space --balance
open -a "WezTerm"
yabai -m window --resize right:-600:0 || yabai -m window --resize left:-600:0

SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[2] ]] && yabai -m space --focus $SPACES[2]
yabai -m space --balance
open -a "Google Chrome"
yabai -m window --resize right:500:0 || yabai -m window --resize left:500:0
