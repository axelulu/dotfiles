#==========================================
#            Zsh Base Inits               #
#=========================================

export BAT_THEME="Nord"
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
export TERM="xterm-256color"  # proper colors# Set name of the theme to
export EDITOR='nvim'
export PATH=$PATH:~/.local/share/nvim/mason/bin
export ZSH_DOTENV_PROMPT=false
export VIRTUAL_ENV_DISABLE_PROMPT=0
#THEME
ZSH_THEME="robbyrussell"

# Add deno completions to search path
# if [[ ":$FPATH:" != *":/Users/axelu/.zsh/completions:"* ]]; then export FPATH="/Users/axelu/.zsh/completions:$FPATH"; fi

#==========================================
#                Extras                  #
#=========================================

## -> External/Plugins
init_extras() {
  echo "$HERE"
source ~/.oh-my-zsh/custom/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste up-line-or-search down-line-or-search expand-or-complete accept-line push-line-or-edit)

# -> init External Scripts
eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"
}

#==========================================
#              Functions                  #
#=========================================

function nnn () {
    command nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
    fi
}

function suyabai () {
  SHA256=$(shasum -a 256 /opt/homebrew/bin/yabai | awk "{print \$1;}")
  if [ -f "/private/etc/sudoers.d/yabai" ]; then
    sudo sed -i '' -e 's/sha256:[[:alnum:]]*/sha256:'${SHA256}'/' /private/etc/sudoers.d/yabai
  else
    echo "sudoers file does not exist yet"
  fi
}

function ya() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	# rm -f -- "$tmp"
}

# Api call helper
function api() {
  if [ "$1" = "get" ]; then
    curl -s "$2" | jless
  elif [ "$1" = "post" ]; then
    curl -s -X POST -d '{}' "$2" | jless
  else
    echo "Invalid operation. Use 'get' or 'post'."
  fi
}

rm_confirm() {
    local confirm
        # If not, proceed with the standard confirmation
        echo -n "Are you sure you wanna run 'rm -rf'? (yes/no): "
        read confirm
        if [ "$confirm" = "yes" ]; then
            command rm  "$@"
        else
            echo "Operation canceled."
        fi
}

# Override git commit with a custom function
git_custom() {
  if [[ $1 == "commit" ]]; then
    sh ~/.config/scripts/git_commit.sh
  elif [[ $1 == "user" ]]; then  # Corrected the syntax here
    sh ~/.config/scripts/git_user.sh
  elif [[ $1 == "push" ]]; then
    sh ~/.config/scripts/git_push.sh
        # Call the original git command for other cases
    command git "$@"

  else
    # Call the original git command for other cases
    command git "$@"
  fi
}

#==========================================
#              Aliases/Exports            #
#=========================================

## -> Aliases

alias src="source ~/.zshrc"
alias cd="z"
alias v="nvim"
alias vim="nvim"
alias clr="clear"
alias home="cd ~"
alias lss="ya"
alias n="nnn"
alias matrix="unimatrix -c blue -u 'Linux'"
alias config="v ~/.zshrc"
alias rm='rm_confirm'
# alias git=git_custom
alias monica="cd $HOME/Desktop/ButterflyEffect/monica/"
alias net="gping www.google.com -c '#88C0D0,#B48EAD,#81A1C1,#8FBCBB'"
alias tree="tre"
alias gp='git pull'
alias go='git pull origin'
alias gb="sh ~/ZERO/SCRIPTS/git_branch.sh"
alias gc="git commit"


## -> Exports
export EDITOR="$(which nvim)"
export VISUAL="$(which nvim)"
export MANPAGER="$(which nvim) +Man!"
export PATH="/Applications/WebStorm.app/Contents/MacOS:$PATH"


# Function to check terminal size
check_terminal_size() {
    if [ "$(tput cols)" -gt 6 ] && [ "$(tput lines)" -gt 6 ]; then
        execute_if_terminal_size_bigger
    else
  export STARSHIP_CONFIG=~/.config/starship_base.toml
  eval "$(starship init zsh)"
    fi
}

# Execute aliases and functions only if terminal size is bigger
execute_if_terminal_size_bigger() {
    # Export aliases,exports and functions,extras
    init_extras
}

check_terminal_size
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
. "/Users/axelu/.deno/env"

# Initialize zsh completions (added by deno install script)
autoload -Uz compinit
compinit

# Added by Windsurf
export PATH="/Users/axelu/.codeium/windsurf/bin:$PATH"
