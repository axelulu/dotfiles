#!/usr/bin/env zsh
# Description: This script is used to teardown the workspaces and apps for work mode

# Get open apps
open_apps=$(osascript ~/.config/scripts/all_running_app.scpt)
# separate the open_apps string by comma into an array
open_apps=(${(s:, :)open_apps})

# Safe apps
WARP="stable"
safe_apps=("Finder" "Raycast" "WezTerm" $WARP)
# Close all apps that are not in the safe apps list

for app in $open_apps; do
  if [[ ! $safe_apps[(r)$app] ]]; then
    echo "Closing $app"
    osascript -e 'quit app "'"$app"'"'
  fi
done
