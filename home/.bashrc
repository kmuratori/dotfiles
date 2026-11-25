# Only run for interactive shells
case "$-" in
    *i*) ;;
      *) return;;
esac

# History behavior
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# fzf options
export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 30% --preview='cat {}'"
export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview"

# Pager
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export LESS="R --use-color -Dd+r -Du+b"
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'

# Aliases
[ -f ~/.config/shell/alias ] && source ~/.config/shell/alias

# Bash completion (if available)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# PS1='\[\e[1;31m\][\[\e[1;33m\]\u\[\e[1;32m\]@\h \[\e[1;34m\]\W\[\e[1;31m\]]\[\e[0m\]\$ '
# ── add to ~/.bashrc ──────────────────────────────────────

__git_branch() {
    local b
    b=$(git symbolic-ref --short HEAD 2>/dev/null) \
        || b=$(git describe --tags --exact-match 2>/dev/null) \
        || b=$(git rev-parse --short HEAD 2>/dev/null)
    [ -n "$b" ] && printf ' (%s)' "$b"
}

PS1='\[\e[31m\][\[\e[33m\]\u\[\e[32m\]@\h \[\e[34m\]\W\[\e[36m\]$(__git_branch)\[\e[31m\]]\[\e[0m\] \[\e[90m\]\A\[\e[0m\] \[\e[31m\]\$\[\e[0m\] '
source ~/.local/share/blesh/ble.sh

# opencode
export PATH=/home/karim/.opencode/bin:$PATH
