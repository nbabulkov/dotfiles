
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
        du -h --max-depth=1 "$dir" | sort -h "$reverse"
        return
    fi
    du -h --max-depth=1 "$dir" | sort -h
}

# Last argument becomes first
revfn() {
    [[ $3 == "" ]] && echo "Usage: $0 [fn] [args...] [last]" && return 1
    fn="$1"
    shift
    last="${@:$#}"
    ind=$(($# - 1))
    others=${@:1:$ind}
    $fn $last $others
}

# NVM NODE
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# MTR without GUI
alias mtrc='mtr --curses'

# Sizes
alias la='ll -ah'
alias lls='ll -Sh'
alias llsa='ll -Sha'
alias dfh='df -h'
alias disksize="df -h | grep '\s/$' --color=NEVER"

# Edit aliases
alias editalias='vim ~/.bash_aliases'

alias ssh-add-github='ssh-add ~/.ssh/github_rsa'

alias gc="gcloud"
alias myip='ip a | grep inet.*global --color=never'
alias netres='service network-manager restart'
alias ca='cursor-agent'

alias ohmyzsh="vim ~/.oh-my-zsh"
alias g="git"
alias p="pnpm"
alias po="poetry"
alias tf="terraform"
alias d="docker"

# BG aliases
alias вя='ls'
alias вв='ll'
alias ъа='cd'
alias эсм='vim'

# Tmux 256 coloured
alias tmux='tmux -2'

# Git grep
alias ggrep='git grep'

# Grep processes
alias psgrep='ps axf | grep'

# Alias for back
alias cb='cd ..'

alias wttr='curl wttr.in/sofia'

# List services
alias services='systemctl list-unit-files | awk "/enabled/ {print \$1}"'

# Edit configs
alias vimrc='vim ~/.vimrc'
alias zshrc='vim ~/.zshrc'
alias sshconf='vim ~/.ssh/config'
alias tmuxconf='vim ~/.tmux.conf'

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

# rm
alias rmrf='rm -rf'

# Universal rm
urm() {
    file="$1"
    [ -d "$file" ] && [ -z "$(ls -A $file)" ] && rmdir "$@" && return
    /bin/rm "$@"
}

# Open postgresql as user postgres
alias pgsql='psql -Upostgres'

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
