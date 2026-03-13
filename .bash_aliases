
# A file for all custom bash aliases:
if command -v eza &> /dev/null; then
    alias ll="eza -l --icons --git --group-directories-first"
    alias la="eza -l -a --icons --git --group-directories-first"
    alias ls="eza --icons"
fi

# Change back directory n times
b () {
    eval cd $(for i in $(seq 1 ${1}); do echo -n '../'; done)
}

# List directory by size
dirsize () {
    reverse=""
    for arg in "$@"; do
        if [[ "$arg" == "-r" ]]; then
            reverse=$arg
            shift
            break
        fi
    done

    dir=$1
    if [[ "$dir" == "" ]]; then
	dir="."
    fi
    if [[ "$reverse" != "" ]]; then
        du -h -d 1 "$dir" | sort -h "$reverse"
        return
    fi
    du -h -d 1 "$dir" | sort -h
}

# Last argument becomes first
revfn() {
    [[ $3 == "" ]] && echo "Usage: $0 [fn] [args...] [last]" && return 1
    local fn="$1"
    shift
    last="${@:$#}"
    ind=$(($# - 1))
    others=${@:1:$ind}
    $fn $last $others
}

# MTR without GUI
alias mtrc='mtr --curses'

# Sizes
alias lls='ll -Sh'
alias llsa='ll -Sha'
alias dfh='df -h'
alias disksize="df -h | grep '\s/$' --color=NEVER"

# Edit aliases
alias editalias="$EDITOR ~/.bash_aliases"

alias ssh-add-github='ssh-add ~/.ssh/github_rsa'
alias ssh-add-google='ssh-add ~/.ssh/google_compute_engine'

llm() {
    local prompt="$1"
    local model="$2"
    if [ -z "$model" ]; then
        local model="qwen/qwen3-4b-2507"
    fi
    lms chat "$model" -p "$prompt" | sd
}
alias gc="gcloud"
alias myip='ip a | grep inet.*global --color=never'
alias netres='service network-manager restart'

alias ze='zellij'
alias e="$EDITOR"
alias g="git"
alias p="pnpm"
alias po="poetry"
alias tf="terraform"
alias d="docker"
alias t="tmux"
alias cl="claude"
alias lg="lazygit"

# BG aliases
alias вя='ls'
alias вв='ll'
alias ъа='cd'
alias вь='la'

# Tmux 256 coloured
alias tmux='tmux -2'

# Git grep
alias ggrep='git grep'

# Grep processes
alias psgrep='ps axf | grep'

# Alias for back
alias cb='cd ..'

# rm
alias rmrf='rm -rf'

# Open postgresql as user postgres
alias pgsql='psql -Upostgres'

alias wttrsf='curl wttr.in/sofia'
alias wttrld='curl wttr.in/london'

# Edit configs
alias vimrc="$EDITOR ~/.vimrc"
alias nvimconf="$EDITOR ~/.config/nvim/init.lua"
alias zshrc="$EDITOR ~/.zshrc"
alias sshconf="$EDITOR ~/.ssh/config"
alias tmuxconf="$EDITOR ~/.tmux.conf"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"

# Activate Python virtual env
activate() {
    venv_dir="$1"
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        echo "Active venv: $VIRTUAL_ENV" 1>&2
        echo "Deactivate it first, before activating other venvs!" 1>&2
        return 1
    fi

    if [[ "$venv_dir" == "" ]]; then
        venv_dir='./.venv'
    fi

    activate_script="$venv_dir/bin/activate"
    if [[ ! -f "$activate_script" ]]; then
        echo "No activation script at: $activate_script" 1>&2
        return 1
    fi
    source "$activate_script"
}

# View markdown
markdown() {
    if [[ "$1" == "" ]]; then
        echo "Usage: $0 <markdown-file>"
        return
    fi
    pandoc "$1" | lynx -stdin
}

# Universal rm
urm() {
    file="$1"
    [ -d "$file" ] && [ -z "$(ls -A $file)" ] && rmdir "$@" && return
    /bin/rm "$@"
}

