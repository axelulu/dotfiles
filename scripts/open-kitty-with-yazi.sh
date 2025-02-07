#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Kitty with Yazi
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author drucial_white
# @raycast.authorURL https://raycast.com/drucial_white

/Applications/WezTerm.app/Contents/MacOS/wezterm -d ~ -e yazi &
