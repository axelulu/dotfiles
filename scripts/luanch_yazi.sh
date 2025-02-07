#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Luanch Yazi
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Launches terminal with yazi running
# @raycast.author drucial_white
# @raycast.authorURL https://raycast.com/drucial_white

cd ~ && /Applications/WezTerm.app/Contents/MacOS/wezterm -e yazi
