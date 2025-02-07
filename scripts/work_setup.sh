#!/usr/bin/env zsh
# Description: This script is used to setup the workspaces and apps for work mode

# Get open apps
open_apps=$(osascript -e 'tell application "System Events" to get the name of every process whose background only is false')
# separate the open_apps string by comma into an array
open_apps=(${(s:, :)open_apps})

# Safe apps
warp="stable"
work_apps=("Finder" "Visual Studio Code" "Google Chrome" "Feishu" "wezterm-gui" $warp)


# Close all apps that are not in the safe apps list
for app in $open_apps; do
  if [[ ! $work_apps[(r)$app] ]]; then
    echo "Closing $app"
    osascript -e 'quit app "'"$app"'"'
  fi
done

# Open apps that are not open
for app in $work_apps; do
  if [[ ! $open_apps[(r)$app] ]]; then
    echo "Opening $app"
    open -a "$app"
  fi
done
