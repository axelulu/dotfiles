#!/usr/bin/env bash
pane_pid=$1
current_file=$(tmux list-panes -F "#{pane_pid} #{pane_current_command} #{pane_current_path}" | grep "^$pane_pid" | awk '{print $3}')
if [ "$(tmux display-message -p -t $pane_pid '#{pane_current_command}')" = "nvim" ]; then
    current_file=$(nvim --headless --noplugin -c 'echo expand("%:p")' -c 'qa' 2>/dev/null)
fi
echo $current_file

