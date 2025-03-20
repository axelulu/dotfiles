# -----------------------------
# Environment and Path Settings
# -----------------------------
export BAT_THEME="Nord"
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
export TERM="xterm-256color"  # proper colors# Set name of the theme to
export EDITOR='nvim'
export VISUAL='nvim'
export ZSH_DOTENV_PROMPT=false
export VIRTUAL_ENV_DISABLE_PROMPT=0
ZSH_THEME="robbyrussell"

# --------------
# zsh Extensions
# --------------
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/functions.zsh
source ~/.config/zsh/git.zsh

# -------
# Plugins
# -------
plugins=(
    z
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-autocomplete
)
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste up-line-or-search down-line-or-search expand-or-complete accept-line push-line-or-edit)
eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"
