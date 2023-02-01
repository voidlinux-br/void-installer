#HISTIGNORE='+([a-z])'
#HISTIGNORE=$'*([\t ])+([-%+,./0-9\:@A-Z_a-z])*([\t ])'
#export TMPDIR=/tmp
#export TMPDIR=/dev/shm
#export LC_ALL="pt_BR.UTF-8"
#export LC_ALL=C
IFS=$' \t\n'
SAVEIFS=$IFS
PROMPT_DIRTRIM=0

tput sgr0 # reset colors
bold=$(tput bold)
reset=$(tput sgr0)
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput bold)$(tput setaf 3)
blue=$(tput setaf 4)
pink=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
orange=$(tput setaf 3)
purple=$(tput setaf 125)
violet=$(tput setaf 61)

#export PS1='\e[32;1m\u \e[33;1m→ \e[36;1m\h \e[37;0m\w\n\e[35;1m�# \e[m'
export PS1="$red\u$yellow@$cyan\h$red $reset\w# "
export PATH=".:/usr/bin:/usr/sbin:/bin:/sbin:/tools/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/.local/bin:$HOME/sbin:$HOME/.cargo/bin"
export CDPATH=".:..:~"
export VISUAL=nano
export EDITOR=nano
alias dd="dd status=progress"
alias wget="wget --no-check-certificate"
alias dmesg="dmesg -T -x"
#set -o noclobber   #bloquear substituicao de arquivo existente
set +o noclobber    #liberar  substituicao de arquivo existente. operator >| ignore the noclobbeer
alias cls=clear
alias ren=mv
alias ls="ls -la --color=auto"
alias dirm="ls -h -ls -Sr --color=auto"
alias dirt="la -h -ls -Sr -rt --color=auto"
alias dir=ls
alias ed=nano
alias du="du -h"
alias dut="du -hs * | sort -h"
alias xcopyn="cp -Rpvan"
alias xcopy="cp -Rpva"
alias copy=cp
alias md=mkdir
alias rd=rmdir
alias del=rm
alias deltraco="rm --"
alias CD=cd
alias cds="cd /etc/runit/runsvdir/current/; ls"
alias cdd="cd /etc/sv/; ls"
alias ddel2="find -iname $1 | xargs rm --verbose"
alias ddel="find -name $1 | xargs rm -fvR"
xdel() { find . -name "*$1*" | xargs rm -fv ; }
tolower() { find . -name "*$1*" | while read; do mv "$REPLY" "${REPLY,,}"; done; }
toupper() { find . -name "*$1*" | while read; do mv "$REPLY" "${REPLY^^}"; done; }
alias fdisk="fdisk -l"
alias portas="nmap -v localhost"
alias port="sockstat | grep ."
alias du="du -h"
alias dut="du -hs * | sort -h"
alias ver="lsb_release -a"
alias versao=ver
alias .1='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias start="sv start $1"
alias stop="sv stop $1"
alias restart="sv restart $1"
alias status="sv status $1"
alias reload="sv reload $1"
alias disable="sv stop $1"
alias rsync="rsync --progress -Cravzp"
alias dcomprimtar="tar -vzxf"
alias targz="tar -xzvf"
alias tarxz="tar -Jxvf"
alias tarbz2="tar -xvjf"
alias untar="tar -xvf"
alias tml="tail -f /var/log/lastlog"
alias ip="ip -c"

#man colour
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

eval $(dircolors -b $HOME/.dircolors)

path() {
   echo -e "${PATH//:/\\n}"
}

