#!/usr/bin/env bash

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
rst=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
pink=$(tput setaf 5)
cyan=$(tput setaf 6)
orange=$(tput setaf 3)
purple=$(tput setaf 125)
violet=$(tput setaf 61)
black=$(tput bold)$(tput setaf 0)
white=$(tput bold)$(tput setaf 7)
yellow=$(tput bold)$(tput setaf 3)

export PS1="$red\u$yellow@$cyan\h$red $reset\w# "
export PS4='${red}${0##*/}${green}[$FUNCNAME]${pink}[$LINENO]${reset} '
#set -x
#set -e
shopt -s extglob
#set -o noclobber   #bloquear substituicao de arquivo existente
set +o noclobber    #liberar  substituicao de arquivo existente. operator >| ignore the noclobbeer
export ROOTDIR=${PWD#/} ROOTDIR=/${ROOTDIR%%/*}
export PATH=".:/usr/bin:/usr/sbin:/bin:/sbin:/tools/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/.local/bin:$HOME/sbin:$HOME/.cargo/bin"
export CDPATH=".:..:~"
export VISUAL=nano
export EDITOR=nano
eval $(dircolors -b $HOME/.dircolors)
ulimit -S -c 0      # Don't want coredumps.

#newbie from windows
alias ls="ls -la --color=auto --group-directories-first"
alias .1='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias ack="ack -n --color-match=red"
alias cls=clear
alias copy=cp
alias dd="dd status=progress"
alias dmesg="dmesg -T -x"
alias dirm="ls -h -ls -Sr --color=auto"
alias dirt="la -h -ls -Sr -rt --color=auto"
alias dir=ls
alias DIR=ls
alias del=rm
alias du="du -h"
alias dut="du -hs * | sort -h"
alias df="df -hT --total"
alias dut="du -hs * | sort -h"
alias dmesg="dmesg -T -x"
alias dmesgerr="dmesg -T -x | grep -P '(:err |:warn )'"
alias discos="udisksctl status"
alias ed=nano
alias ED=nano
alias fs="file -s"
alias dcomprimtar="tar -vzxf"
alias deltraco="rm --"
alias disable="sv stop $1"
alias CD=cd
alias cds="cd /etc/runit/runsvdir/current/; ls"
alias cdd="cd /etc/sv/; ls"
alias ddel="find -name $1 | xargs rm -fvR"
alias ddel2="find -iname $1 | xargs rm --verbose"
alias fdisk="fdisk -l"
alias ip="ip -c"
alias l=dir
alias listen="netstat -anp | grep :"
alias mem="free -h"
alias md=mkdir
alias ouvindo="netstat -anp | grep :"
alias ouvindo="netstat -anp | grep :"
alias ports="sockstat | grep ."
alias portas="nmap -v localhost"
alias portas1="lsof -i | grep ."
alias pyc="python -OO -c 'import py_compile; py_compile.main()'"
alias rd=rmdir
alias ren=mv
alias rsync="rsync --progress -Cravzp"
alias reload="sv reload $1"
alias restart="sv restart $1"
alias start="sv start $1"
alias stop="sv stop $1"
alias status="sv status $1"
alias smbmount="mount -t cifs -o username=$USER,password=senha //10.0.0.68/c /root/windows"
alias tml="tail -f /var/log/lastlog"
alias targz="tar -xzvf"
alias tarxz="tar -Jxvf"
alias tarbz2="tar -xvjf"
alias untar="tar -xvf"
alias ver="lsb_release -a"
alias versao=ver
alias wget="wget --no-check-certificate"
alias xcopyn="cp -Rpvan"
alias xcopy="cp -Rpva"

#harbour
alias rmake="[ ! -d /tmp/.hbmk ] && { mkdir -p /tmp/.hbmk; }; hbmk2 -info -comp=gcc   -cpp=yes -jobs=36"
#alias rmake="hbmk2 -info -comp=clang -cpp=yes -jobs=36"

#man colour
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

#log_msgs
NORMAL="${reset}"            # Standard console grey
SUCCESS="${green}"           # Success is green
WARNING="${yellow}"          # Warnings are yellow
FAILURE="${red}"             # Failures are red
INFO="${cyan}"               # Information is light cyan
BRACKET="${blue}"            # Brackets are blue
BMPREFIX="     "
DOTPREFIX="  ${blue}::${reset} "
SUCCESS_PREFIX="${SUCCESS}  *  ${NORMAL}"
FAILURE_PREFIX="${FAILURE}*****${NORMAL}"
WARNING_PREFIX="${WARNING}  W  ${NORMAL}"
SKIP_PREFIX="${INFO}  S  ${NORMAL}"
SUCCESS_SUFFIX="${BRACKET}[${SUCCESS}  OK  ${BRACKET}]${NORMAL}"
FAILURE_SUFFIX="${BRACKET}[${FAILURE} FAIL ${BRACKET}]${NORMAL}"
WARNING_SUFFIX="${BRACKET}[${WARNING} WARN ${BRACKET}]${NORMAL}"
SKIP_SUFFIX="${BRACKET}[${INFO} SKIP ${BRACKET}]${NORMAL}"
WAIT_PREFIX="${WARNING}  R  ${NORMAL}"
WAIT_SUFFIX="${BRACKET}[${WARNING} WAIT ${BRACKET}]${NORMAL}"
FAILURE_PREFIX="${FAILURE}  X  ${NORMAL}"

path()				{ echo -e "${PATH//:/\\n}"; }
xdel()				{ find . -name "*$1*" | xargs rm -fv ; }
tolower()			{ find . -name "*$1*" | while read; do mv "$REPLY" "${REPLY,,}"; done; }
toupper()			{ find . -name "*$1*" | while read; do mv "$REPLY" "${REPLY^^}"; done; }
has()					{ command -v "$1" >/dev/null; }
printeradd()		{ addprinter "$@"; }
lsd() 				{ printf "${blue}\n"; ls -l | awk '/^d/ {print $9}'; printf "${reset}"; }
lsa() 				{ echo -n ${orange}; ls -l | awk '/^-/ {print $9}'; }
filehoracerta() 	{ export SOURCE_DATE_EPOCH=$(date +%s); find . -exec touch -h -d @$SOURCE_DATE_EPOCH {} + ; }
horacerta() 		{ sudo ntpd -q -g; sudo hwclock --systohc; }
GREP_OPTIONS() 	{ GREP_OPTIONS='--color=auto'; }
email() 				{ echo "CORPO" | mail -s "Subject" -A /etc/bashrc teste@balcao; }
log_wait_msg() 	{ printf "${BMPREFIX}${@}"; printf "${CURS_ZERO}${WAIT_PREFIX}${SET_COL}${WAIT_SUFFIX}\n";return 0; }
log_success_msg()	{ printf "${BMPREFIX}${@}"; printf "${CURS_ZERO}${SUCCESS_PREFIX}${SET_COL}${SUCCESS_SUFFIX}\n"; return 0; }

addprinter() {
	sudo cupsctl --remote-any --share-printers
	sudo lpadmin -p LPT1 -E -v ipp://10.0.0.99/p1 -L "EPSON LX300 em Atendimento" -m everywhere -o print-is-shared=true -u allow:all
	sudo lpadmin -p LPT2 -E -v socket://10.0.0.99 -m everywhere -o print-is-shared=true -u allow:all
	sudo lpadmin -p LPT3 -E -v ipp://10.0.0.99/p2 -m everywhere -o print-is-shared=true -u allow:all
	sudo lpadmin -p LPT4 -E -v ipp://10.0.0.99/p3 -m everywhere -o print-is-shared=true -u allow:all
	sudo lpadmin -p SAMSUNG2070 -E -v ipp://10.0.0.77/ipp/print -m everywhere -o print-is-shared=true -u allow:all
	sudo lpadmin -p DeskJet -E -v parallel:/dev/lp0 -m everywhere -u allow:all
	sudo lpadmin -p DotMatrix -E -m epson9.ppd -v serial:/dev/ttyS0?baud=9600+size=8+parity=none+flow=soft -u allow:all
	sudo lpadmin -p PRINTERNAME -E -v smb://10.0.0.68/P1 -L "LOCATION" -o auth-info-required=negotiate -u allow:all
	sudo lpadmin -d LPT1
}

sshsemsenha() {
	_SERVIDOR=$1
	echo $1
	ssh-keygen -t rsa
	ssh-copy-id -p 22 -f -i ~/.ssh/id_rsa.pub $_SERVIDOR
}

xdel1() {
	arr=$(find -iname "${1}")
	echo "${arr[*]}"
	for i in "${arr[*]}"; do
		rm -f $i
	done
}

rdel() {
	for i in `find -iname "$1"`; do
		rm -f $i
	done
}

delr() {
	for i in `find -iname "$1"`
	do
		rm -f $i
	done
}

void-ramdisk() {
	sudo mkdir /mnt/ramdisk
	sudo mount -t tmpfs -o size=4096M tmpfs /mnt/ramdisk
	#fstab
	#tmpfs       /mnt/ramdisk tmpfs   nodev,nosuid,noexec,nodiratime,size=512M   0 0
}

void-qemuimg() {
	if test $# -ge 1; then
		qemu-system-x86_64 -no-fd-bootchk -nographic $1
	else
	cat <<EOF
usage:
	void-qemuimg <file>
EOF
	fi
}

void-qemu() {
	qemu-system-x86_64 -m 4096 -no-fd-bootchk -nographic -cdrom $1
}

void-qemux() {
	qemu-system-x86_64 -curses -no-fd-bootchk -nographic -cdrom $1
}

void-qemukvm() {
	qemu-system-x86_64 -enable-kvm -m 2048 -name 'VOID OS' -boot -cdrom $1
}

void-qemurunraw() {
	if test $# -ge 1; then
		qemu-system-x86_64 \
			-display curses \
			-no-fd-bootchk \
			-drive format=raw,file=$1 \
			-m "size=8128,slots=0,maxmem=$((8128*1024*1024))"
	else
		cat <<EOF
usage:
	void-qemurunraw file.img
EOF
	fi
}

void-qemu-img-create() {
	local image=$1
	local type=$2
	local size=$3

	if test $# -ge 3; then
		qemu-img create $image -f $type $size
		qemu-img info $image
	else
		cat <<EOF
usage:
	void-qemu-img-create filename type size
	=========================================
	${pink}Raw${reset} 		Raw is default format if no specific format is specified while creating disk images.
	Qcow2		Qcow2 is opensource format developed against Vmdk and Vdi. Qcow2 provides features like compression,
	Qed		Qed is a disk format provided by Qemu. It provides support for overlay and sparse images. Performance of Qed is better than Qcow2 .
	Qcow		Qcow is predecessor of the Qcow2.
	Vmdk		Vmdk is default and popular disk image format developed and user by VMware.
	Vdi		Vdi is popular format developed Virtual Box. It has similar features to the Vmdk and Qcow2
	Vpc		Vps is format used by first generation Microsoft Virtualization tool named Virtual PC. It is not actively developed right now.
	=========================================
	'size' is the disk image size in bytes. Optional suffixes
	'k' or 'K' (kilobyte, 1024),
	'M' (megabyte, 1024k),
	'G' (gigabyte, 1024M),
	'T' (terabyte, 1024G),
	'P' (petabyte, 1024T) and
	'E' (exabyte, 1024P)

	void-qemu-img-create void.img raw 10M
	void-qemu-img-create debian.qcow2 qcow2 10G
EOF
	fi
}

void-qemu-img-convert-raw-to-qcow2() {
	if test $# -ge 2; then
		qemu-img convert -f raw $1 -O qcow2 $2
	else
		cat <<EOF
usage:
	void-qemu-img-convert-img-to-qcow2 hda0.img hda1.qcow2
EOF
	fi
}

void-qemu-img-convert-vdi-to-raw() {
	if test $# -ge 2; then
		qemu-img convert -f vdi -O raw $1 $2
	else
		cat <<EOF
usage:
	void-qemu-img-convert-vdi-to-raw image.vdi image.img
EOF
	fi
}

void-qemurunqcow2() {
	qemu-system-x86_64 	\
      -drive file=$1,if=none,id=disk1 \
      -device ide-hd,drive=disk1,bootindex=1 \
      -m "size=8192,slots=0,maxmem=$((8192*1024*1024))" \
		-k br-abnt2 		\
      -vga virtio 		\
		-smp 16 				\
      -machine type=q35,smm=on,accel=kvm,usb=on \
		-enable-kvm
}

void-qemurunuefi() {
	image=$1
	if test $# -ge 1; then
	   local ovmf_code='/usr/share/edk2-ovmf/x64/OVMF_CODE.fd'
	   local ovmf_vars='/usr/share/edk2-ovmf/x64/OVMF_VARS.fd'
	   local working_dir="$(mktemp -dt run_archiso.XXXXXXXXXX)"

	   sudo qemu-system-x86_64 \
	     -enable-kvm \
	     -cpu host \
	     -smp 36 \
	     -m 8192 \
	     -drive file=${image},if=virtio,format=raw \
        -m "size=8128,slots=0,maxmem=$((8128*1024*1024))" \
	     -device virtio-net-pci,netdev=net0 -netdev user,id=net0 \
	     -vga virtio \
	     -display gtk \
	     -device intel-hda \
	     -audiodev pa,id=snd0,server=localhost \
	     -device hda-output,audiodev=snd0 \
	     -net nic,model=virtio \
	     -net user \
	     -drive if=pflash,format=raw,unit=0,file=${ovmf_code},read-only=off \
	     -drive if=pflash,format=raw,unit=1,file=${ovmf_vars} \
	     -enable-kvm \
	     -serial stdio
	else
	cat <<EOF
usage:
	void-qemurunuefi file.img
	void-qemurunuefi file.qcow2
EOF
	fi
}
#        -hda /archlive/qemu/hda.img 	\
#        -hdb /archlive/qemu/hdb.img 	\
#       	-display curses    				\
#        -vga virtio 						\

void-qemurunfile() {
   if test $# -ge 1; then
        sudo qemu-system-x86_64 \
        -no-fd-bootchk     \
        -drive file=${1},if=none,id=disk1 \
        -device ide-hd,drive=disk1,bootindex=1 \
        -m "size=8128,slots=0,maxmem=$((8128*1024*1024))" \
        -name archiso,process=archiso_0 \
        -device virtio-scsi-pci,id=scsi0 \
        -audiodev pa,id=snd0,server=localhost \
        -device ich9-intel-hda \
        -device hda-output,audiodev=snd0 \
        -device virtio-net-pci,romfile=,netdev=net0 -netdev user,id=net0,hostfwd=tcp::60022-:22 \
        -global ICH9-LPC.disable_s3=1 \
        -machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
        "${qemu_options[@]}" \
         -smp 36 \
         -enable-kvm \
        -serial stdio
   else
   cat <<EOF
usage:
   void-qemurunfile file.img
   void-qemurunfile file.qcow2
EOF
   fi
}
#        -hda /archlive/qemu/hda.img \
#        -hdb /archlive/qemu/hdb.img \
#        -hdc /archlive/qemu/hdc.img \
#        -hdd /archlive/qemu/hdd.img \
#       -vga virtio     \
#        -display "sdl" \
#       -device qxl-vga,vgamem_mb=128 \
#        -k br-abnt2 \

void-qemufilerun()	{ void-qemurunfile $@ ;}
filerun()				{ void-qemurunfile $@; }
fr()						{ void-qemurunfile $@; }
fru()						{ void-qemurunuefi $@; }
frr()						{ void-qemurunimg $@; }
fileinfo()				{ qemu-img info $@; }
export -f fr
export -f void-qemurunfile

frc() {
	if test $# -ge 1; then
 		  sudo qemu-system-x86_64 \
 		  -no-fd-bootchk		\
        -drive file=${1},if=none,id=disk1 \
        -device ide-hd,drive=disk1,bootindex=1 \
		  -hda /archlive/qemu/hda.img \
        -hdb /archlive/qemu/hdb.img \
        -hdc /archlive/qemu/hdc.img \
        -hdd /archlive/qemu/hdd.img \
        -m "size=8128,slots=0,maxmem=$((8128*1024*1024))" \
        -name archiso,process=archiso_0 \
        -device virtio-scsi-pci,id=scsi0 \
        -audiodev pa,id=snd0,server=localhost \
        -device ich9-intel-hda \
        -device hda-output,audiodev=snd0 \
        -device virtio-net-pci,romfile=,netdev=net0 -netdev user,id=net0,hostfwd=tcp::60022-:22 \
        -global ICH9-LPC.disable_s3=1 \
        -machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
  	  	  -display curses    \
	      "${qemu_options[@]}" \
         -smp 36 \
         -enable-kvm \
        -serial stdio
	else
	cat <<EOF
usage:
	frc file.img
	frc file.qcow2
EOF
	fi
}

rf() {
	if test $# -ge 1; then
 		  qemu-system-x86_64 \
        -m "size=8128,slots=0,maxmem=$((8128*1024*1024))" \
        -hda ${1} \
        -smp 18 \
        -enable-kvm
	else
	cat <<EOF
usage:
	rf hda.qcow2
	rf hdb.img
EOF
	fi
}

void-qemurunimg() {
	if test $# -ge 1; then
 		  qemu-system-x86_64 \
        -drive file=${1},format=raw,if=none,id=disk1 \
        -device ide-hd,drive=disk1,bootindex=1 \
        -m "size=8128,slots=0,maxmem=$((8128*1024*1024))" \
        -k br-abnt2 \
        -name archiso,process=archiso_0 \
        -device virtio-scsi-pci,id=scsi0 \
        -display "sdl" \
        -vga virtio \
        -audiodev pa,id=snd0,server=localhost \
        -device ich9-intel-hda \
        -device hda-output,audiodev=snd0 \
        -device virtio-net-pci,romfile=,netdev=net0 -netdev user,id=net0,hostfwd=tcp::60022-:22 \
        -machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
        -global ICH9-LPC.disable_s3=1 \
        -smp 16 \
        -enable-kvm \
        "${qemu_options[@]}" \
        -serial stdio
	else
	cat <<EOF
usage:
	void-qemurunimg hda.img
	void-qemurunimg hdb.img
EOF
	fi
}

void-qemu-dos() {
	qemu-system-x86_64 -m 128 -name 'Microsoft MSDO 7.1' -hda /home/vcatafesta/Downloads/qemu/dos7.qcow2
}

maketap() {
	#need uml-utilities
	sudo modprobe tun
	sudo tunctl -t tap0
	sudo ifconfig tap0 0.0.0.0 promisc up
	sudo ifconfig enp3s0 0.0.0.0 promisc up
	sudo brctl addbr br0
	sudo brctl addif br0 tap0
	#sudo brctl addif br0 enp3s0
	sudo brctl show
	sudo ifconfig br0 up
	sudo ifconfig br0 10.7.7.66/24
}

vlanubnt() {
	#telnet 10.0.0.51
	#ssh 10.0.0.51
	vconfig add br0 5
	vconfig add br0 10
	ifconfig br0.5 x.x.x.x netmask x.x.x.x up
	ifconfig br0.10 x.x.x.x netmask x.x.x.x up
}

void-videoultrahd() {
	sudo xrandr --newmode "2560x1080_60.00"  230.00  2560 2720 2992 3424  1080 1083 1093 1120 -hsync +vsync
	sudo xrandr --addmode HDMI-0 2560x1080_60.00
}

tms() {
	sudo dmesg -w -T -x
}

lsvideo() {
	echo -e "1. xrandr"
	sudo xrandr
	echo
	echo -e "2. grep -i chipset /var/log/Xorg.0.log"
	sudo grep -i chipset /var/log/Xorg.0.log
	echo
	echo -e "3. lshw -C video"
	sudo lshw -C video
	echo
	echo -e "4. sudo lspci -k | grep -A 2 -E '(VGA|3D)'"
	sudo lspci -k | grep -A 2 -E '(VGA|3D)'
	echo -e '5. sudo lspci -nnkd::0300'
	sudo lspci -nnkd::0300
}
export -f lsvideo

ddel3() {
	find -iname $1 | xargs rm --verbose
}

net() {
	echo "Iniciando rede"
	ip addr add 10.0.0.67/21 dev enp0s3
	ip route add default via 10.0.0.254 dev enp0s3
	ip route list
}

gpull() {
	log_wait_msg "${blue}Iniciando git pull ${reset}"
	sudo git config credential.helper store
#	sudo git config pull.ff only
#	sudo git pull
	sudo git pull --no-ff
}

gpush() {
	log_wait_msg "${red}Iniciando git push ${reset}"
	sudo git config credential.helper store
#	sudo git add .
	sudo git add -A
	sudo git commit -m "$(date) nome_do_usuario (usuario@gmail.com)"
	sudo git push --force
}

gto() {
	log_wait_msg "${red}Mudando para ${reset}: $1"
	git checkout $1
}

gclean(){
	#Execute o seguinte comando para fazer backup do seu branch atual:
	sudo git branch backup_branch
	#Execute o seguinte comando para criar um novo branch a partir do atual, mas sem nenhum histórico de commits:
	sudo git checkout --orphan new_branch
	#Agora, todos os arquivos do projeto aparecerão como "untracked". Adicione todos eles ao staging area com o comando:
	sudo git add .
	#Comite os arquivos com uma mensagem de confirmação:
	sudo git commit -m "Initial commit"
	#Finalmente, sobrescreva o branch atual com o novo branch criado:
	sudo git branch -M new_branch
}

cpd() {
	TITLE='Copiando...'
	MSG='Copiando o diretório $ORIGEM para $DESTINO'
	INTERVALO=1       # intervalo de atualização da barra (segundos)
	PORCENTO=0        # porcentagem inicial da barra
	#................................................................
	ORIGEM="${1%/}"
	DESTINO="${2%/}"
	#................................................................
	die()    { echo "Erro: $*" ; }
	sizeof() { du -s "$1" | cut -f1; }
	running(){ ps $1 | grep $1 >/dev/null; }

	#................................................................

	# tem somente dois parâmetros?
	[ "$2" ] || die "Usage: $0 dir-origem dir-destino"

	# a origem e o destino devem ser diretórios
	#[ -d "$ORIGEM"  ] || die "A origem '$ORIGEM' deve ser um diretório"
	#[ -d "$DESTINO" ] || die "O destino '$DESTINO' deve ser um diretório"

	# mesmo dir?
	[ "$ORIGEM" = "$DESTINO" ] &&
		die "A origem e o destino são o mesmo diretório"

	# o diretório de destino está vazio?
	DIR_DESTINO="$DESTINO/${ORIGEM##*/}"
	[ -d "$DIR_DESTINO" ] && [ $(sizeof $DIR_DESTINO) -gt 4 ] &&
		die "O dir de destino '$DIR_DESTINO' deveria estar vazio"

	#................................................................

	# expansão das variáveis da mensagem
	MSG=$(eval echo $MSG)

	# total a copiar (em bytes)
	TOTAL=$(sizeof $ORIGEM)

	# início da cópia, em segundo plano
	cp $ORIGEM $DESTINO &
	CPPID=$!

	# caso o usuário cancele, interrompe a cópia
	trap "kill $CPPID" 2 15

	#................................................................

	# loop de checagem de status da cópia
	(
		# enquanto o processo de cópia estiver rodando
		while running $CPPID; do
			# quanto já foi copiado?
			COPIADO=$(sizeof $DIR_DESTINO)
			# qual a porcentagem do total?
			PORCENTAGEM=$((COPIADO*100/TOTAL))
			# envia a porcentagem para o dialog
			echo $PORCENTAGEM
			# aguarda até a próxima checagem
			sleep $INTERVALO
		done
		# cópia finalizada, mostra a porcentagem final
		echo 100
	) | dialog --title "$TITLE" --gauge "$MSG" 8 40 0
	#................................................................
	#echo OK - Diretório copiado
}

remountpts() {
	log_wait_msg "Desmontando: sudo umount -rl /dev/pts"
	sudo umount -rl /dev/pts
	log_wait_msg "Remontando: sudo mount devpts /dev/pts -t devpts"
	sudo mount devpts /dev/pts -t devpts
}

makepy() {
	local filepy="ex.py"
   log_wait_msg "Aguarde, criando arquivo $1..."
   if [ "${1}" != "" ]; then
   	filepy="${1}"
   fi

   cat > ${filepy} << "EOF"
#!/usr/bin/python3
# -*- coding: utf-8 -*-
EOF
	chmod +x ${filepy}
	log_success_msg "Feito! ${cyan}'$filepy' ${reset}criado on $PWD"
}

mkpy()       { makepy "$@"; }
makescript() {	makebash "$@"; }
mks()        {	makebash "$@"; }

makebash() {
	prg='script.sh'
	if test $# -ge 1; then
		prg="$1"
		[[ -e "$prg" ]] && { msg "${red}Arquivo $1 já existe. Abortando..."; return; }
	fi
   log_wait_msg "Aguarde, criando arquivo $prg on $PWD"
   cat > "$prg" << "EOF"
#!/usr/bin/env bash

EOF
   sudo chmod +x $prg
	#echo $(replicate '=' 80)
   #cat $prg
	#echo $(replicate '=' 80)
	log_success_msg "Feito! ${cyan}'$prg' ${reset}criado on $PWD"
}

alias l=$PWD
alias pkgdir=$PWD
alias srcdir=${PWD#/} srcdir=/${srcdir%%/*}
alias r=$OLDPWD
alias c="cd /sources"

ex() {
	if [ -f $1 ] ; then
   	case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.tar.xz)    tar Jxvf $1     ;;
            *.lz)        lzip -d -v $1   ;;
            *.chi)       tar Jxvf $1     ;;
            *.chi.zst)   tar -xvf $1     ;;
            *.tar.zst)   tar -xvf $1     ;;
            *.mz)        tar Jxvf $1     ;;
            *.cxz)       tar Jxvf $1     ;;
            *.chi)       tar Jxvf $1     ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Make your directories and files access rights sane.
sanitize() {
	chmod -R u=rwX,g=rX,o= "$@"
}

renane() {
	for f in $1; do
		mv "$f" ${f/$1/$2 }
	done
}

zerobyte() {
	for f in "$1" ; do >| "$f" ; done
}
export -f zerobyte

xwinserver() {
	# Windows XSrv config
	export $(dbus-launch)
	export LIBGL_ALWAYS_INDIRECT=1
	export WSL_VERSION=$(wsl.exe -l -v | grep -a '[*]' | sed 's/[^0-9]*//g')
	export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2)
	export DISPLAY=$WSL_HOST:0
}

void-makeramdrive() {
	sudo modprobe zram >/dev/null
	sudo umount -f /dev/ram0 >/dev/null
	[ ! -e /dev/ram0 ] && sudo mknod -m 0777 /dev/ram0 b 1 0 >/dev/null
	[ ! -e /dev/ram0 ] && sudo dd if=/dev/zero of=/dev/ram0
	[ ! -d /run/ramdrive ] && sudo mkdir -p /run/ramdrive >/dev/null
	sudo mkfs.ext4 -F /dev/ram0 -L RAMDRIVE
	sudo mount /dev/ram0 /run/ramdrive
	sudo ln -sf /run/ramdrive /ram

	#sudo vgcreate VG0 /dev/ram0
	#sudo vgextend VG0 /dev/ram1
	#sudo lvcreate -L 8G -n DADOS VG0
	#sudo mkfs.ext4 /dev/mapper/VG0-DADOS
	#sudo mount /dev/mapper/VG0-DADOS /run/ramdrive
}

#Criando um novo repositório por linha de comando
makegit() { void-makegitcodeberg "$@"; }
void-makegitcodeberg() {
	touch README.md
	git init
	git checkout -b main
	git add README.md
	git commit -m "first commit"
	git remote add origin https://codeberg.org/usuario/teste.git
	git push -u origin main
}

#Realizando push para um repositório existente por linha de comando
makepush() { void-makepush "$@"; }
void-makepush() {
	git remote add origin https://codeberg.org/usuario/teste.git
	git push -u origin main
}

ssherror() { void-correctionssherror "$@"; }
void-correctionssherror() {
	{
	echo -n 'Ciphers '
	ssh -Q cipher | tr '\n' ',' | sed -e 's/,$//'; echo
	echo -n 'MACs '
	ssh -Q mac | tr '\n' ',' | sed -e 's/,$//'; echo
	echo -n 'HostKeyAlgorithms '
	ssh -Q key | tr '\n' ',' | sed -e 's/,$//'; echo
	echo -n 'KexAlgorithms '
	ssh -Q kex | tr '\n' ',' | sed -e 's/,$//'; echo
	} >> ~/.ssh/config
}

sh_ascii-lines() {
	if [[ "$LANG" =~ 'UTF-8' ]]; then
		export NCURSES_NO_UTF8_ACS=0
	else
		export NCURSES_NO_UTF8_ACS=1
	fi
}

virtualbox-add-nic() {
	for nic in {2..10}; do
		VBoxManage modifyvm "chr" --nic$nic bridged --nictype$nic 82540EM --bridgeadapter$nic enp6s0
	done
}

fcopy() {
	find . -name "*$1*" -exec cp -v {} /tmp \;
}

glibc-version() {
	sudo ldd --version
	sudo ldd `which ls` | grep libc
	sudo /lib/libc.so.6
}

void-mkfstab() {
	#cp /proc/mounts >> /etc/fstab
	sed 's/#.*//' /etc/fstab | column --table --table-columns SOURCE,TARGET,TYPE,OPTIONS,PASS,FREQ --table-right PASS,FREQ
}
void-mapadd() { sudo kpartx -uv $1; }
void-mapdel() { sudo kpartx -dv $1; }

fid() {
	if [ $# -eq 0 ]; then
		echo 'Usage: fid "*.c"'
		echo '       fid "*"'
		echo $(find . -iname "*" -type f | wc -l)
		return
	fi
	filepath=$1
	echo $(find . -type f -iname "$filepath" | wc -l)
}

ff() {
	if [ $# -eq 0 ]; then
		echo 'Usage: ff "*.c"'
		echo '       ff "*.c" | xargs commando'
		echo '       ff "*.c" | xargs cp -v /tmp'
		sudo find . -type f -iname '*'"$*"'*' -ls
	fi
	filepath=$1
	sudo find . -type f,d,l -name "$filepath" -ls
}

ffe() {
	[ "$1" ] || {
		echo "Usage: ffe 'grep search'   | xargs comando";
		echo "       ffe 'grep search";
		echo "       ffe 'executable' | xargs rm -fv";
		echo "       ffe 'ELF|ASCII|MP4' | xargs rm -fv";
		echo "       ffe 'ELF|ASCII|MP4' | xargs cp -v /tmp"; return;
	}
	sudo find . -type f,d,l -exec file {} + | grep -iE "($1)" | cut -d: -f1
}

ffs() {
	[ "$1" ] || {
		echo "Usage: ffs 'search' '*.doc' | xargs comando"
		echo "       ffs 'def |function ' '*.prg'"
		echo "       ffs '#include' '*.*'"
		echo "       ffs 'search|search|texto' '*.txt' | xargs rm -fv"
		echo "       ffs 'ELF|ASCII|MP4' '*.doc' | xargs cp -v /tmp"
		return;
	}
	sudo grep -r --color=auto -n -iE "($1)" $2;
	sudo find . -type f -iname '*'"$2"'*' -exec grep --color=auto -n -iE "($1)" {} +;
}

void-xcopynparallel() {
	find $1 | parallel -j+0 cp -Rpvan {} $2
}
