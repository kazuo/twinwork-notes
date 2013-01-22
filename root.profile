# 2002/12/28
#
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/X11R6/bin
export PATH
HOME=/root
export HOME
TERM=${TERM:-cons25}
export TERM
PAGER=less
export PAGER
BLOCKSIZE=K
export BLOCKSIZE
EDITOR=ee
export EDITOR

PS1="\u@\h:\w"
case `id -u` in
0) PS1="${PS1}# ";;
*) PS1="${PS1}$ ";;
esac
export PS1

alias 'ls'='gnuls -F --color=auto --show-control-chars -h'
alias 'dir'='gnuls -F --color=auto --show-control-chars -h'

alias 'vi'='vim'

ENV=$HOME/.shrc
export ENV
