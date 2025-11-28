# ============================
#   .bashrc ROOT — Void Linux
# ============================
# Só continua se for shell interativo
[[ $- != *i* ]] && return

# Histórico decente
HISTSIZE=5000
HISTFILESIZE=5000
HISTCONTROL=ignoredups:erasedups

# Editor padrão
export EDITOR=vim
export VISUAL=vim

# Função de status (SEM COR – PS1 colore)
get_exit_status() {
   local status="$?"
   [[ $status -eq 0 ]] && printf "✔" || printf "✘%d" "$status"
}
# Prompt ROOT — vermelho, com status ✔/✘ colorido
export PS1='\[\033[1;31m\]\u\[\033[1;33m\]@\[\033[1;36m\]\h\[\033[1;31m\]:\w \
$( if [[ $? -eq 0 ]]; then printf "\033[1;32m✔"; else printf "\033[1;31m✘\033[1;35m%d" $?; fi ) \
\[\033[0m\]# '

# Alias úteis
alias ll='ls -lh --color=auto'
alias la='ls -A --color=auto'
alias l='ls --color=auto'
if command -v "eza" >/dev/null 2>&1; then
   alias dir='eza -la --color=auto --icons'
   alias ls='eza'
else
   alias dir='ls -la --color=auto'
fi
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -ht'
alias ed='nano'
alias xcopy='cp -Rpva'
alias ddel='find -name | xargs sudo rm -fvR'

# ----- GRC-RS Configuration -----
GRC="/usr/bin/grc"
if tty -s && [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && command -v "$GRC" >/dev/null 2>&1; then
	alias colourify="$GRC"
	commands=(
		ant blkid configure df diff dig dnf docker-machine docker images
		docker info docker network docker ps docker pull docker search docker version
		du fdisk findmnt go-test ifconfig ip ipaddr ipneighbor iproute iptables
		irclog iwconfig kubectl last ldap lolcat lsattr lsblk lsmod lsof lspci
		lsusb mount mtr mvn netstat nmap ntpdate ping proftpd pv
		semanage boolean semanage fcontext semanage user sensors showmount sockstat
		ss stat sysctl tcpdump traceroute tune2fs ulimit uptime vmstat wdiff yaml efibootmgr duf
	)
	for cmd in "${commands[@]}"; do
		if command -v "$cmd" >/dev/null 2>&1; then
			alias "$cmd"="colourify $cmd"
		fi
	done
	unset commands cmd
fi

# Autocompletar (se existir)
if [ -f /etc/bash/bashrc.d/complete.bash ]; then
	. /etc/bash/bashrc.d/complete.bash
fi

# PATH extra
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Cores - Substitua pelos códigos ANSI do seu terminal, se necessário
GREEN="\033[1;32m"   # Verde
GREEN='\e[92m'
RED="\033[1;31m"     # Vermelho
RED='\033[38;5;196m'
YELLOW="\033[1;33m"  # Amarelo
BLUE="\033[1;34m"    # Azul
MAGENTA="\033[1;35m" # Magenta
CYAN="\033[1;36m"    # Ciano
RESET="\033[0m"      # Resetar as cores
negrito="\033[0;1m"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
   debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
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

# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [ "$color_prompt" = yes ]; then
	# override default virtualenv indicator in prompt
	VIRTUAL_ENV_DISABLE_PROMPT=1

	reset='\[\033[0m\]'
	light_red='\[\e[38;5;203m\]'
	vermelho='\[\e[38;5;196m\]'
	amarelo='\[\e[38;5;226m\]'
	verde='\[\e[38;5;40m\]'
	verde_brilhante='\[\e[92m\]'
	cyan='\[\e[38;5;51m\]'
	branco='\[\e[97m\]'
	negrito='\[\033[0;1m\]'
	prompt_color='\[\033[;32m\]'
	info_color='\[\033[1;34m\]'
	color_user="$branco"
	prompt_symbol=㉿
	if [ "$EUID" -eq 0 ]; then # Change prompt colors for root user
		prompt_color='\[\033[;94m\]'
		info_color='\[\033[1;31m\]'
		color_user="$vermelho"
		# Skull emoji for root terminal
		#        prompt_symbol=💀
		#        prompt_symbol=📡
		#        prompt_symbol=⚡
		#        prompt_symbol=✨
		prompt_symbol=👮
		#        prompt_symbol=😎
		#        prompt_symbol=🔞
	else
		prompt_symbol=💁‍
		prompt_symbol=🦾
	fi

	# Função para obter o status do último comando
	function get_exit_status() {
	   local status="$?"
	   if [ $status -eq 0 ]; then
	      printf "${RESET}${status} ${GREEN}✔ ${RESET}"
	   else
	      printf "${YELLOW}${status} ${RED}✘ "
	   fi
	}

	case "$PROMPT_ALTERNATIVE" in
	twoline)
		PS1=$prompt_color'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+($red$(basename $VIRTUAL_ENV)'$prompt_color')}\
('$prompt_symbol''$color_user'\u'$amarelo'@'$cyan'\h'$prompt_color')-'$negrito'\w'$prompt_color']$(get_exit_status)\n└─\$ '
		;;
	oneline)
		PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}'$info_color'\u@\h\[\033[00m\]:'$prompt_color'\[\033[01m\]\w\[\033[00m\]\$ '
		;;
	backtrack)
		PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
		;;
	esac
	unset prompt_color
	unset info_color
	unset prompt_symbol
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt* | Eterm | aterm | kterm | gnome* | alacritty)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

[ "$NEWLINE_BEFORE_PROMPT" = yes ] && PROMPT_COMMAND="PROMPT_COMMAND=echo"
