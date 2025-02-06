# -----------------------------
# Environment and Path Settings
# -----------------------------
export BAT_THEME="Nord"
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
export TERM="xterm-256color"  # proper colors# Set name of the theme to
export EDITOR='nvim'
export VISUAL='nvim'
export PATH=$PATH:~/.local/share/nvim/mason/bin
export ZSH_DOTENV_PROMPT=false
export VIRTUAL_ENV_DISABLE_PROMPT=0
#THEME
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
source ~/.oh-my-zsh/custom/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste up-line-or-search down-line-or-search expand-or-complete accept-line push-line-or-edit)
eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"

# -------
# Exports
# -------
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
# Added by Windsurf
export PATH="/Users/axelu/.codeium/windsurf/bin:$PATH"
export GITLAB_TOKEN=glpat-XMS_DRWd11EQxiKsmNRF
