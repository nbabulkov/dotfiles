export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="my"

plugins=(
  git
  gh
  tig
  golang
  tmux
  poetry
  python
  postgres
  pip
  pyenv
  sudo
  fzf
  vscode
  docker
  gcloud
  nvm
  npm
  macos
  ssh-agent
  colored-man-pages
  web-search
  zsh-interactive-cd
)

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Aliases
[ -s ~/.bash_aliases ] && source ~/.bash_aliases

# Export local bins
export PATH="$HOME/.local/bin:$PATH"

# Set all configs to read from home dir .config
export XDG_CONFIG_HOME="$HOME/.config"

if [ -d /opt/homebrew ]; then
    export PATH="/opt/homebrew/bin:$PATH"
    # Postgres
    [ -d /opt/homebrew/opt/postgresql@18/bin ] && export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"
fi

# Deno completions
[ -s ~/.deno/env ] && source ~/.deno/env

# Bun completions
[ -s ~/.bun/_bun ] && source ~/.bun/_bun

# Zellij
eval "$(zellij setup --generate-auto-start zsh)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Zoxide 
eval "$(zoxide init zsh)"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

