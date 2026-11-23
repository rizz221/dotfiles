# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export PATH=$HOME/.local/bin:$PATH
. "$HOME/.cargo/env"




pathadd() {
    local dir
    for dir in "$@"; do
        dir="${dir%/}"
        [ -d "$dir" ] || continue
        case ":$PATH:" in
            *":$dir:"*) ;;
            *) PATH="$dir:$PATH" ;;
        esac
    done
    export PATH
}



# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Listing
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -A'
alias lt='ls -ltrh'          # newest last

# Safety nets
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'            # prompt once for 3+ files
alias mkdir='mkdir -pv'

# Grep / disk / memory
alias grep='grep --color=auto'
alias df='df -hT'
alias du='du -h'
alias free='free -h'
alias duh='du -h --max-depth=1 | sort -h'

# Processes / network
alias psg='ps aux | grep -i'
alias ports='ss -tulpn'
alias myip='curl -s https://icanhazip.com ; echo'
alias ping='ping -c 5'

# Misc
alias h='history | tail -30'
alias c='clear'
alias please='sudo $(fc -ln -1)'   # rerun last command with sudo
alias reload='source ~/.bashrc'
alias path='echo -e ${PATH//:/\\n}'

# Git
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gco='git checkout'

# Systemd
alias sc='sudo systemctl'
alias scu='systemctl --user'
alias jc='journalctl -xeu'



# mkdir + cd
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# Universal extractor
extract() {
  [ -f "$1" ] || { echo "'$1' is not a file"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar.zst)        tar --zstd -xf "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.zip)            unzip "$1" ;;
    *.rar)            unrar x "$1" ;;
    *.7z)             7z x "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *)                echo "Don't know how to extract '$1'" ;;
  esac
}

# Quick backup of a file
bak() { cp -v -- "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)"; }

# Find files by name
ff() { find . -iname "*$1*" 2>/dev/null; }

# Find text in files (uses rg if available)
fg() {
  if command -v rg >/dev/null; then rg -n "$@"
  else grep -rnI --color=auto "$@" .; fi
}

# cd then list
cl() { cd -- "$1" && ls -A; }

# Go up N directories: up 3
up() { local d=""; for ((i=0; i<${1:-1}; i++)); do d+="../"; done; cd "$d"; }

# Kill process by name (interactive with fzf if available)
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  [ -n "$pid" ] && echo "$pid" | xargs kill -${1:-9}
}

# Show what's listening on a port
whoport() { sudo ss -tulpn | grep ":$1"; }

# Quick HTTP server in current dir
serve() { python3 -m http.server "${1:-8000}"; }

# Make a file executable and open it
nx() { touch "$1" && chmod +x "$1" && ${EDITOR:-vi} "$1"; }

# Biggest files/dirs here
big() { du -ah "${1:-.}" 2>/dev/null | sort -rh | head -${2:-20}; }

# Weather
wttr() { curl -s "wttr.in/${1:-}?format=3"; }

# Cheat sheets
cheat() { curl -s "cheat.sh/$1"; }

# Quick git commit-all
gca() { git add -A && git commit -m "$*"; }

# Fuzzy cd (needs fzf)
fcd() {
  local dir
  dir=$(find "${1:-.}" -type d 2>/dev/null | fzf) && cd "$dir"
}



eval "$(fzf --bash)"
