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
alias dir='ls -la --color=auto'
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
		ant blkid configure df diff dig dnf docker-machine ls docker images
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

#!/usr/bin/env bash

# ========== CHROOT USADO NO PROMPT ==========
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# ========== DETECÇÃO BÁSICA DE COR ==========
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# Força prompt colorido
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# tem suporte a cor
		color_prompt=yes
	else
		color_prompt=
	fi
fi

# ========== CONFIG PADRÃO KALI ==========
# (essas variáveis são usadas no bloco abaixo)
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes

if [ "$color_prompt" = yes ]; then
	# desabilita o prefixo padrão do virtualenv
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

	if [ "$EUID" -eq 0 ]; then
		# root: outras cores e símbolo
		prompt_color='\[\033[;94m\]'
		info_color='\[\033[1;31m\]'
		color_user="$vermelho"
		prompt_symbol=👮
	else
		# user normal (acabou ficando esse último símbolo configurado)
		prompt_symbol=🦾
	fi

	# Função para mostrar status do último comando
	get_exit_status() {
		local status="$?"
		if [ "$status" -eq 0 ]; then
			# verde com ✔
			printf "${reset}${status} ${verde_brilhante}✔ ${reset}"
		else
			# amarelo/vermelho com ✘
			printf "${amarelo}${status} ${vermelho}✘ ${reset}"
		fi
	}

	case "$PROMPT_ALTERNATIVE" in
	twoline)
		# Linha dupla, estilo Kali tunado
		PS1=$prompt_color'┌──${debian_chroot:+($debian_chroot)──}''${VIRTUAL_ENV:+($vermelho$(basename $VIRTUAL_ENV)'"$prompt_color"')}\'$'\n''('"$prompt_symbol""$color_user"'\u'"$amarelo"'@'"$cyan"'\h'"$prompt_color"')-'"$negrito"'\w'"$prompt_color"']$(get_exit_status)\n└─\$ '
		;;
	oneline)
		# Linha única (versão simplificada, baseada no Kali)
		PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }''${debian_chroot:+($debian_chroot)}'"$prompt_color"'\[\033[01;31m\]\u@\h\[\033[00m\]:'"$prompt_color"'\[\033[01m\]\w\[\033[00m\]\$ '
		;;
	backtrack)
		# Estilo Debian clássico colorido
		PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }''${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:''\[\033[01;34m\]\w\[\033[00m\]\$ '
		;;
	esac

	unset prompt_color info_color prompt_symbol
else
	# Prompt simples, sem cor
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

# ========== TÍTULO DA JANELA (xterm, konsole, etc) ==========
case "$TERM" in
xterm* | rxvt* | Eterm | aterm | kterm | gnome* | alacritty)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

# ========== LINHA EM BRANCO ANTES DO PROMPT ==========
[ "$NEWLINE_BEFORE_PROMPT" = yes ] && PROMPT_COMMAND="PROMPT_COMMAND=echo"
