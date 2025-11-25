# 🔥   Tutorial de instalação do Void Linux com Btrfs + Subvolumes + LUKS + Swapfile + UEFI (Guia Completo)
(Somente UEFI, sem BIOS/Legacy)

## Iniciar a Instalação
Inicie pelo ISO do Void Linux (x86_64 glibc ou musl).

1. Entre como root
```
login    : root
password : voidlinux
```
2. Troque o shell de sh para o bash. O dash/sh NÃO suporta várias coisas que muitos scripts usam.
```
bash
```
3. Troque o layout de teclado para ABNT2
```bash
loadkeys br-abnt2
```
4. Cole no terminal (opcional) — Prompt com cores, usuário@host:caminho e status do último comando (✔/✘). Útil e bonito.
```
get_exit_status() {
  local status="$?"
  [[ $status -eq 0 ]] && printf "✔" || printf "✘%d" "$status"
}
export PS1='\[\033[1;32m\]\u\[\033[1;33m\]@\[\033[1;36m\]\h\[\033[1;31m\]:\w \
$( [[ $? -eq 0 ]] && printf "\033[1;32m✔" || printf "\033[1;31m✘\033[1;35m%d" $? ) \
\[\033[0m\]\$ '
```
# Conectar à Internet
- Para Wi-Fi *(se estiver no cabo, pule esta etapa)*:
```
wpa_passphrase "SSID" "SENHA" > wifi.conf
wpa_supplicant -B -i wlan0 -c wifi.conf
dhcpcd wlan0
```

1. Testar a conexão:
```
ping -c3 8.8.8.8
ping -c3 repo-default.voidlinux.org
```

2. Instale alguns necessários pacotes:
```
xbps-install -Sy xbps parted nano zstd xz bash-completion
```

## Particionar o disco
1. Identificar o disco
```bash
fdisk -l
```
> Assumiremos para o tutorial `/dev/sda`

2. Altere abaixo, conforme o disco que será usado (IMPORTANTE):
```
DEVICE=/dev/sda
DEV_UFI=/dev/sda1
DEV_RAIZ=/dev/sda2
```

3. Usando o parted (automatico)
```
parted --script ${DEVICE} -- \
    mklabel gpt \
    mkpart ESP fat32 1MiB 512MiB set 1 esp on name 1 EFI \
    mkpart ROOT btrfs 512MiB 100% name 2 ROOT \
    align-check optimal 1
parted --script ${DEVICE} -- print
```
4. Usando o cfdisk (manualmente)
```bash
cfdisk -z ${DEVICE}
```
Selecione **GPT**

- **ESP** — EFI System Partition — 512MB — tipo *EFI System*
- **Sistema (Btrfs)** — resto do disco — tipo *Linux filesystem*

> Salve e saia.

## Formatar partições

```bash
# Criptografar a partição raiz em LUKS1 (compatível com GRUB)
# Criptografar partição Btrfs Confirmando com YES:  
cryptsetup luksFormat --type luks1 ${DEV_RAIZ}

# Abra a partição com sua passphrase. Será montada e mapeada, escolha um nome qualquer, aqui escolheremos cryptroot:
cryptsetup open ${DEV_RAIZ} cryptroot

# Formatar como Btrfs o dispositivo montado pelo cryptsetup no /dev/mapper, com o nome que setamos cryptroot:
mkfs.btrfs /dev/mapper/cryptroot

# Formatar ESP:
mkfs.fat -F32 ${DEV_EFI}
```

## Criar subvolumes BTRFS
```bash
# Monte o dispositivo cryptroot em /mnt e crie nele seus subvolumes
mount /dev/mapper/cryptroot /mnt

# Cria subvolumes essenciais
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@snapshots

# Desmonte o dispositivo:
umount /mnt
```

## Montar os subvolumes do sda2/cryptroot no /mnt:

```bash
# O subvolume principal (@)
mount -o subvol=@ /dev/mapper/cryptroot /mnt

# Cria os pontos de montagem (incluindo os do chroot)
mkdir -p /mnt/{home,boot/efi,var/log,var/cache,.snapshots,dev,proc,sys,run}

# Monta os subvolumes restantes
mount -o subvol=@home      /dev/mapper/cryptroot /mnt/home
mount -o subvol=@log       /dev/mapper/cryptroot /mnt/var/log
mount -o subvol=@cache     /dev/mapper/cryptroot /mnt/var/cache
mount -o subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# monte EFI:
mount ${DEV_EFI} /mnt/boot/efi
```

## Instalar o sistema base
```
xbps-install -Sy -R https://repo-default.voidlinux.org/current \
   -r /mnt \
   base-system btrfs-progs cryptsetup grub-x86_64-efi dracut linux \
   linux-headers linux-firmware linux-firmware-network glibc-locales \
   xtools dhcpcd openssh vim nano grc zstd xz bash-completion vpm vsv
```

## Isso garante:

- btrfs-progs → necessário para os subvolumes
- cryptsetup → para LUKS
- dracut → initramfs com suporte a LUKS
- grub-x86_64-efi → bootloader UEFI
- linux → kernel
- linux-firmware-network → drivers de rede
- xtools → obrigatório para usar xgenfstab sem falhas

## Criar fstab
```
xgenfstab -U /mnt > /mnt/etc/fstab

# sobrescreve os pontos importantes do fstab
sed -i 's|subvol=@ |subvol=@,compress=zstd:3,noatime,ssd,discard=async,space_cache=v2,commit=300 |' /mnt/etc/fstab
sed -i 's|subvol=@home |subvol=@home,compress=zstd:3,noatime,ssd,discard=async,space_cache=v2,commit=300 |' /mnt/etc/fstab
sed -i 's|subvol=@cache |subvol=@cache,noatime,ssd,discard=async,space_cache=v2,commit=300 |' /mnt/etc/fstab
sed -i 's|subvol=@log |subvol=@log,noatime,ssd,discard=async,space_cache=v2,commit=300 |' /mnt/etc/fstab
sed -i 's|subvol=@snapshots |subvol=@snapshots,compress=zstd:3,noatime,ssd,discard=async,space_cache=v2,commit=300 |' /mnt/etc/fstab
```

## Entrar no sistema (chroot)
1. Entrar no chroot:
```
xchroot /mnt /bin/bash
```
## Configurar GRUB
```bash
# Pegar a UUID da partição sda2:
UUID=$(blkid -s UUID -o value ${DEV_RAIZ})
echo ${UUID}

# Adicionando ao /etc/default/grub
cat << EOF >> /etc/default/grub
# Linha de parâmetros do kernel — LUKS1 abre no GRUB sem drama
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.luks.uuid=${UUID} rd.luks.name=${UUID}=cryptroot root=/dev/mapper/cryptroot"
# Habilita suporte a criptografia no GRUB
GRUB_ENABLE_CRYPTODISK=y
# Módulos necessários (LUKS1)
GRUB_PRELOAD_MODULES="luks cryptodisk gcry_rijndael"
EOF

# Crie o path para suportar o grub
mkdir -p /boot/grub

# Gerar o novo grub.cfg
grub-mkconfig -o /boot/grub/grub.cfg
```

## Instalação do Boot Manager GRUB em UEFI
```bash
# Instale o novo GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=void --recheck

# Criar fallback UEFI (boot universal) - Esse arquivo garante boot mesmo quando a NVRAM for apagada.
mkdir -p /boot/efi/EFI/BOOT
cp -vf /boot/efi/EFI/void/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
```

## Gerando o INITRAMFS
```
mods=(/usr/lib/modules/*)
KVER=$(basename "${mods[0]}")
echo ${KVER}
dracut --force --kver ${KVER}
```

## Criar o keyfile para evitar pedir senha duas vezes
Quando o GRUB abre o LUKS, o initramfs normalmente pede a senha de novo.
Para evitar isso, vamos criar um keyfile, colocar dentro do initramfs e deixar o root abrir sozinho.
```
#criar o keyfile
dd if=/dev/urandom of=/boot/volume.key bs=64 count=1
chmod 000 /boot/volume.key

#Adicionar o keyfile ao LUKS
cryptsetup luksAddKey ${DEV_RAIZ} /boot/volume.key     # Digite sua senha LUKS (a mesma usada no GRUB).

#Configurar o /etc/crypttab
cat << EOF >> /etc/crypttab
cryptroot ${DEV_RAIZ} /boot/volume.key  luks
EOF

#Incluir o keyfile no initramfs
cat << EOF >> /etc/dracut.conf.d/10-crypt.conf
install_items+=" /boot/volume.key /etc/crypttab "
EOF

#Regenerar o initramfs
xbps-reconfigure -fa
```
>Isso recria o initramfs com:
- keyfile incluído
- crypttab incluído
- hooks de LUKS funcionando

## Configurações básicas
```bash
# Setar Hostname
echo void > /etc/hostname

# Setar Localtime
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Setar Locales
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/default/libc-locales
sed -i 's/#pt_BR.UTF-8/pt_BR.UTF-8/' /etc/default/libc-locales

# Gerar locales:
xbps-reconfigure -f glibc-locales

# Ativar alguns serviços:
ln -sf /etc/sv/dhcpcd /var/service/
ln -sf /etc/sv/sshd /var/service/

# Criar um resolv.conf
printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf

#Configurar sudo - grupo wheel (opcional)
cat << 'EOF' > /etc/sudoers.d/g_wheel
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
EOF
#Permissões obrigatórias
chmod 440 /etc/sudoers.d/g_wheel

# Criar o usuário (opcional)
NEWUSER=seunomeaqui
useradd -m -G audio,video,wheel,tty -s /bin/bash ${NEWUSER}
passwd ${NEWUSER}
```

## Trocar senha de root (importante):
```bash
passwd root
```

## Criar swapfile em Btrfs (opcional)
```
btrfs filesystem mkswapfile --size 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab
```

## Personalizar o /etc/xbps.d/00-repository-main.conf (opcional)
- Cria o diretório de configurações do XBPS (se ainda não existir) e adiciona uma lista de repositórios oficiais e alternativos.
Os repositórios repo-fastly costumam ter melhor latência.
```
mkdir -pv /etc/xbps.d
cat << 'EOF' >> /etc/xbps.d/00-repository-main.conf
repository=https://repo-fastly.voidlinux.org/current
#repository=https://repo-fastly.voidlinux.org/current/nonfree
#repository=https://repo-fastly.voidlinux.org/current/multilib
#repository=https://repo-fastly.voidlinux.org/current/multilib/nonfree

repository=https://void.chililinux.com/voidlinux/current
#repository=https://void.chililinux.com/voidlinux/current/extras
#repository=https://void.chililinux.com/voidlinux/current/nonfree
#repository=https://void.chililinux.com/voidlinux/current/multilib
#repository=https://void.chililinux.com/voidlinux/current/multilib/nonfree
EOF
```
## Personalizar o /etc/rc.conf (opcional)
- Define o fuso horário, layout do teclado e fonte padrão do console. Altere conforme necessidade.
```
cat << 'EOF' >> /etc/rc.conf
TIMEZONE=America/Sao_Paulo
KEYMAP=br-abnt2
FONT=Lat2-Terminus16
EOF
```

## Personalizar o .bashrc do usuario (opcional)
Cria um .bash_profile para o usuário e garante que o .bashrc seja carregado automaticamente no login.
- confira se criou o usuário no passo anterior
```
cat << 'EOF' > /home/${NEWUSER}/.bash_profile
# ~/.bash_profile — carrega o .bashrc no Void

# Se o .bashrc existir, carregue
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
EOF

cat << 'EOF' > /home/${NEWUSER}/.bashrc
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

# grc aliases
alias ping='grc ping'
alias ping6='grc ping6'
alias traceroute='grc traceroute'
alias traceroute6='grc traceroute6'
alias netstat='grc netstat'
alias ifconfig='grc ifconfig'
alias ip='grc ip'
alias mount='grc mount'
alias ps='grc ps'
alias diff='grc diff'
alias gcc='grc gcc'
alias make='grc make'
alias df='grc df'
alias du='grc du'
alias duf='grc duf'
alias dig='grc dig'
alias dmesg='grc dmesg'

# Autocompletar (se existir)
if [ -f /etc/bash/bashrc.d/complete.bash ]; then
  . /etc/bash/bashrc.d/complete.bash
fi
# PATH extra
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
EOF
```
## configurar ssh (opcional)
```
mkdir -pv /etc/ssh/sshd_config.d/
cat << 'EOF' > /etc/ssh/sshd_config.d/10-custom.conf
PermitTTY yes
PrintMotd yes
PrintLastLog yes
Banner /etc/issue.net

PermitRootLogin yes
KbdInteractiveAuthentication yes
X11Forwarding yes
PubkeyAuthentication yes
PubkeyAcceptedKeyTypes=+ssh-rsa
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication yes
ChallengeResponseAuthentication yes
UsePAM yes

Subsystem sftp internal-sftp
EOF
```

## Sair do chroot
```
exit
```

```
# Desmonta todas as partições montadas em /mnt (subvolumes e /boot/efi)
umount -R /mnt

# Desativa qualquer swapfile ou swap partition que tenha sido ativada dentro do chroot
swapoff -a

# Fecha o mapeamento LUKS (desbloqueio do cryptroot)
cryptsetup close cryptroot
```

```
# Reinicia a máquina física ou a VM para testar o boot real
reboot
```
---
---

## DICA: Trocar a senha principal do LUKS
> Inicie com o live iso

1. Esse é o comando oficial, limpo e correto:
```
cryptsetup luksChangeKey /dev/sda2
```
> **Ele vai pedir:**  
> • Senha atual  
> • Nova senha  
> • Confirmar a nova senha  

2. Testar se a nova senha funciona
```
cryptsetup open /dev/sda2 testpass
cryptsetup close testpass
```
> Se abrir → senha nova OK.

---

# 🎉   Enjoy!
O Void Linux agora está instalado com:

- 🔐 LUKS  
- 🗂️ Btrfs + subvolumes  
- 📁 swapfile dentro do Btrfs (seguro)  
- ⚙️ Boot UEFI limpo  


