DOTS=$HOME/.config/

#-------------------
# Directories
#-------------------

alias home="cd ~"
alias dev='cd $HOME/Dev'
alias dots='cd $DOTS'
alias scripts='cd $DOTS/scripts'
alias nodejs='cd $HOME/Dev/nodejs/'
alias react='cd $HOME/Dev/react/'
alias extensions='cd $HOME/Dev/extensions/'
alias monica='cd $HOME/Dev/ButterflyEffect/monica/'

#-------------------
# Locations
# ------------------

alias axelupi='ssh axelu@axeludeMacBook-Pro.local'

#-------------------
# VNC
# ------------------

alias start-vnc="sudo systemctl start x11vnc.service"
alias check-vnc="sudo systemctl status x11vnc.service"
alias kill-vnc="sudo systemctl stop x11vnc.service"

#-------------------
# Files
#-------------------

alias e_zsh='nvim ~/.config/zsh/.zshrc'
alias e_nvim='nvim ~/.config/nvim'
alias e_alias='nvim ~/.config/zsh/aliases.zsh'
alias e_warp='nvim ~/.warp/themes/Celestial.yaml'
alias e_kitty='nvim ~/.config/kitty/kitty.conf'
alias e_gitconfig='nvim ~/.gitconfig'
alias e_starship='nvim ~/.config/starship/starship.toml'
alias e_bat='nvim ~/.config/bat/config'
alias e_yabai='nvim ~/.config/yabai/yabairc'
alias e_dots='code ~/.config'
alias e_monica='code $HOME/Dev/ButterflyEffect/monica'
alias e_intelli_link='code $HOME/Dev/react/intelli-link'

#-------------------
# Shortcuts
#-------------------

alias ip='echo $(curl -s ipinfo.io) | jq '.'; curl -s ipinfo.io/ip | pbcopy; echo "IP address copied to cliboard."'
alias n='nvim'
alias v="nvim"
alias vim="nvim"
alias y='yazi'
alias be='bundle exec'
alias f='yazi'
alias rm='rm_confirm'
alias ff="nvim \$(fzf --preview 'bat --style=numbers --color=always {}' --preview-window '~3')"
alias cat='bat'
alias ls='lsd'
alias cd='z'
alias lsl='lsd -l'
alias lsa='lsd -a'
alias lsla='lsd -la'
alias lst='ls --tree --depth 2'
alias s_zsh='source ~/.config/zsh/.zshrc'
alias src="source ~/.zshrc"
alias screen='screen -c ~/.config/screen/.screenrc'
alias lss="ya"
alias n="nnn"
alias net="gping www.google.com -c '#88C0D0,#B48EAD,#81A1C1,#8FBCBB'"
alias tree="tre"

#-------------------
# CLI Utilities
# ------------------

alias c='clear'
alias h='history'
alias x='exit'
alias e="~/.config/scripts/nvim_wrapper.sh"

#-------------------
# Git
#-------------------

alias gg='lazygit'
alias gst='git status'
alias gco='git checkout'
alias gcom='git checkout master'
alias gcod='git checkout dev'
alias gcob='git checkout -b'
alias gcm='git commit -m'
alias gcam='git commit --all -m'
alias gb='git branch'
alias ga='git add'
alias gaa='git add -A'
alias gpo='git pull'
alias gpsup='git push --set-upstream origin $(git_branch_name)'
alias ghpr='open_github_pr'
alias gdc='git diff main | pbcopy && echo "Diff copied to clipboard."'

#-------------------
# Scripts
# ------------------

alias convert_movs='~/.config/scripts/convert_mov_files.sh'
alias convert_nucleo_icons='~/.config/scripts/convert_nucleo_icons.sh'
alias luanch_yazi='~/.config/scripts/luanch_yazi.sh'
alias nvim_wrapper='~/.config/scripts/nvim_wrapper.sh'
alias optimize_images='~/.config/scripts/optimize_images.sh'
alias process_images_for_web='~/.config/scripts/process_images_for_web.sh'
alias renamefiles='~/.config/scripts/rename_files.sh'
alias resizeimage='~/.config/scripts/resize_image.sh'
alias tmux_current_file='~/.config/scripts/tmux_current_file.sh'
alias open_yazi='~/.config/scripts/open_yazi.sh'
alias openwork='~/.config/scripts/work_setup.sh'
alias openworkmini='~/.config/scripts/work_setup_mini_screen.sh'
alias closework='~/.config/scripts/work_teardown.sh'
alias hsreload="osascript -e 'tell application \"Hammerspoon\" to execute lua code \"hs.reload()\"'"

# windows
alias focus_window='~/.config/scripts/windows/focus_window.sh'
alias move_window_to_left='~/.config/scripts/windows/move_window_to_left.sh'
alias move_window_to_right='~/.config/scripts/windows/move_window_to_right.sh'
alias open_wezterm='~/.config/scripts/windows/open_wezterm.sh'
alias taggle_show_hide_desktop='~/.config/scripts/windows/taggle_show_hide_desktop.sh'
alias window_focus_on_destroy='~/.config/scripts/windows/window_focus_on_destroy.sh'

#-------------------
# Notes
# ------------------

alias note='cd ~/Notes && nvim ~/Notes/$(date +"%B_%d_%Y").md'
alias editnotes='cd ~/Notes && nvim ~/Notes'
alias notes='ls --tree ~/Notes'

#-------------------
# Functions
#-------------------

alias addalias='add_alias'
alias removealias='remove_alias'
alias updatealiasname='update_alias_name'
alias updatealiascommand='update_alias_command'

#-------------------
# Generated Aliases
#-------------------
alias check_net_speed='~/.config/scripts/check_wifi_speed_gui.sh'
alias k_sketchy="kill $(ps -ef | grep /opt/homebrew/opt/sketchybar/bin/sketchybar | grep -v grep | awk 'NR==1 {print $2}')"
alias k_sketchy_bottom="kill $(ps -ef | grep /opt/homebrew/bin/sketchy_bottombar | grep -v grep | awk 'NR==1 {print $2}')"
alias png2webp="~/.config/scripts/png2Webp/png2Webp.sh"
alias code_replace='code . -r'
alias next-agent='cd /Users/axelu/Dev/ButterflyEffect/next-agent'
alias clear_arch_linux='sudo ~/.config/scripts/arch-cleanup.sh'
