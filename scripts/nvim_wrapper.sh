#!/usr/bin/env zsh

# Source the script to access the set_name function
source ~/.scripts/set_terminal_tab_title.sh

# Run the set_name function
set_name

# Execute nvim with any passed arguments
command nvim "$@"
