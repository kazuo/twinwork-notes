# 2002/12/28
#
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/X11R6/bin; export PATH
HOME=/root; export HOME
TERM=${TERM:-cons25}; export TERM
PAGER=more; export PAGER
BLOCKSIZE=K; export BLOCKSIZE
EDITOR=vim; export EDITOR

if [ -z "${BASH}" ]; then
    PS1="\u@\h:\w"
    case `id -u` in
        0) PS1="${PS1}# ";;
        *) PS1="${PS1}$ ";;
    esac
    cd
    export PS1

    alias 'ls'='gnuls -F --color=auto --show-control-chars -h'
fi

ENV=$HOME/.shrc; export ENV
alias 'vi'='vim'
