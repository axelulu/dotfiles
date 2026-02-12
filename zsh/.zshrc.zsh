# ==========================
# Oh My Zsh
# ==========================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(z git zsh-syntax-highlighting zsh-autocomplete zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# ==========================
# Terminal Switcher
# ==========================
source ~/.config/terminal.conf
export TERMINAL TERMINAL_APP TERMINAL_BIN TERMINAL_CONFIG

# ==========================
# Environment
# ==========================
export TERM="xterm-256color"
export EDITOR='nvim'
export VISUAL='nvim'
export BAT_THEME="Nord"
export ZSH_DOTENV_PROMPT=false
export VIRTUAL_ENV_DISABLE_PROMPT=0

# ==========================
# Custom Config
# ==========================
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/functions.zsh
source ~/.config/zsh/git.zsh

# ==========================
# Shell Tools
# ==========================
eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"

# ==========================
# NVM
# ==========================
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ==========================
# Bun
# ==========================
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ==========================
# PATH
# ==========================
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# ==========================
# Secrets (not tracked by git)
# ==========================
[ -f "$HOME/.env" ] && source "$HOME/.env"
