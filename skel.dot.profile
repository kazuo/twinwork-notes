# 2003/07/08
#
# .profile - Bourne Shell startup script for login shells
#
# see also sh(1), environ(7).
#

# remove /usr/games and /usr/X11R6/bin if you want
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:$HOME/bin; export PATH

# Setting TERM is normally done through /etc/ttys. Do only override
# if you're sure that you'll never log in via telnet or xterm or a
# serial line.
# Use cons25l1 for iso-* fonts
# TERM=cons25; export TERM

BLOCKSIZE=K; export BLOCKSIZE
EDITOR=vim; export EDITOR
PAGER=more; export PAGER

if [ ! -z "${BASH}" ]; then
    PS1="\u@\h:\w"
    case `id -u` in
        0) PS1="${PS1}# ";;
        *) PS1="${PS1}$ ";;
    esac
    cd
    export PS1

    alias 'ls'='gnuls -F --color=auto --show-control-chars -h'
fi

# set ENV to a file invoked each time sh is started for interactive use.
ENV=$HOME/.shrc; export ENV
alias 'vi'='vim'