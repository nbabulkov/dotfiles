
# A file for all custom bash aliases:

alias myip='ip a | grep inet.*global --color=never'
alias netres='service network-manager restart'

# Change back directory n times
function b () {
    eval cd $(for i in $(seq 1 ${1}); do echo -n '../'; done)
}

# List directory by size
function dirsize () {
	dir=$1
	if [ -z "$dir" ]; then
		dir="."
	fi
	du -h --max-depth=1 "$dir" | sort -h -r
}
alias g='git'

# Edit aliases
alias editalias='vim ~/.bash_aliases'

alias ssh-add-github='ssh-add ~/.ssh/github_rsa'

# BG aliases
alias вя='ls'
alias вв='ll'
alias ъа='cd'
alias эсм='vim'

# Exa aliases
alias le='exa -lh'
alias la='exa -lha'

# Tmux 256 coloured
alias tmux='tmux -2'

# Git grep
alias ggrep='git grep'

# Gitk all
alias gik="gitk --all"

# Grep processes
alias psgrep='ps axf | grep'

# Current IP address
alias myip='ip a | grep "inet.*global" | cut -d" " -f-6'

# Google
alias ggl="googler"

# Alias for back
alias cb='cd ..'

alias wttr='curl wttr.in/sofia'

# List services
alias services='systemctl list-unit-files | awk "/enabled/ {print \$1}"'

alias bashreload='source ~/.bashrc'

# Open cpp files
alias cpp='vim *.h *.hpp *.cpp 2> /dev/null || vim *.h *.cpp 2> /dev/null || vim *.hpp *.cpp 2> /dev/null || vim *.cpp'

alias vimrc='vim ~/.vimrc'

# Activate python venv
venvactivate() {
    activation_script="./venv/bin/activate"
    if [ "$1" != "" ]; then
        activation_script="$1/bin/activate"
    fi
    source $activation_script
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
