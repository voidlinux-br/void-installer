# 🧩 TUTORIAL VOID LINUX + BTRFS + SUBVOLUMES + HIBERNAÇÃO + ZRAM  
### VERSÃO REVISADA E VALIDADA — SISTEMA HÍBRIDO (UEFI + BIOS) — COM ORDEM CORRETA DAS PARTIÇÕES

Este guia instala um Void Linux totalmente **híbrido**, capaz de dar boot em:

- Máquinas UEFI novas 
- Máquinas BIOS/Legacy antigas 
- PCs com NVRAM apagada 
- Sistemas OEM problemáticos 
- Qualquer máquina onde você espetar o SSD 

📌 **Sem reinstalar GRUB, sem mudar partições, sem frescura.** 
📌 **Tudo graças ao uso conjunto de ESP + BIOS Boot + fallback UEFI.**

---

# ▶️ 1. Bootar o Live ISO

Use a versão glibc pela compatibilidade superior:

```
https://repo-default.voidlinux.org/live/current/void-live-x86_64-20250202-base.iso
```
ou procure a última versão em:
```
https://voidlinux.org/download/
```

1. Entre como root.
```
```

2. Troque o shell de sh para o bash. O dash/sh NÃO suporta várias coisas que muitos scripts usam.
```
bash
```

3. Cole no terminal:
```
get_exit_status() {
  local status="$?"
  [[ $status -eq 0 ]] && printf "✔" || printf "✘%d" "$status"
}
export PS1='\[\033[1;32m\]\u\[\033[1;33m\]@\[\033[1;36m\]\h\[\033[1;31m\]:\w \
$( [[ $? -eq 0 ]] && printf "\033[1;32m✔" || printf "\033[1;31m✘\033[1;35m%d" $? ) \
\[\033[0m\]\$ '
```

# ▶️ 2. Conectar à Internet
Configurar Wi-Fi *(se estiver usando cabo, pule esta etapa)*:
```
wpa_passphrase "SSID" "SENHA" > wifi.conf
wpa_supplicant -B -i wlan0 -c wifi.conf
dhcpcd wlan0
```

1. Testar conexão com a Internet:
```
ping 8.8.8.8
ping google.com
```

2. Instale alguns necessários pacotes:
```
xbps-install -Sy xbps parted vpm vsv nano zstd xz
```
---

# ▶️ 3. Identificar o disco
Listar os discos disponíveis e anotar o nome do dispositivo (ex: `/dev/sda`, `/dev/vda`, `/dev/nvme0n1`):
```
fdisk -l
```

Assumiremos para o tutorial /dev/sda
---

# ▶️ 4. Criar tabela GPT + Partições (ORDEM CORRETA)
A partição BIOS **DEVE** ser a primeira. 
Isso aumenta compatibilidade com placas-mãe antigas, bootloaders problemáticos e BIOS que esperam o código de boot nas primeiras áreas do disco.
A ESP pode vir depois sem problema algum — UEFI não liga para a posição.

### Ordem ideal:
1️⃣ BIOS Boot (EF02)
2️⃣ ESP (EFI System, FAT32)
3️⃣ Btrfs (raiz)
---

1. Criar as partições:
Usando o parted (automatico)
```
parted --script /dev/sda -- \
    mklabel gpt \
    mkpart primary fat32 1MiB 2MiB set 1 bios on name 1 BIOS \
    mkpart primary fat32 2MiB 512MiB set 2 esp on name 2 EFI \
    mkpart primary btrfs 512MiB 100% name 3 ROOT \
    align-check optimal 1
parted --script /dev/sda -- print
```

ou use o fdisk (manualmente)
```
fdisk /dev/sda
```

No fdisk:
```
g                      # cria GPT

# 1 – BIOS BOOT (primeira partição)
n                      # 1–2 MB
t → EF02               # tipo BIOS Boot

# 2 – ESP (segunda)
n                      # 512 MB
t → 1                  # EFI System Partition

# 3 – Partição principal Btrfs
n                      # restante do disco

w
```
---

# ▶️ 5. Formatar as partições
```
mkfs.fat -F32 /dev/sda2     # ESP (2ª partição)
mkfs.btrfs -f /dev/sda3     # Btrfs (3ª partição)
```

verifique:
```
lsblk -f /dev/sda
```
---

# ▶️ 6. Criar subvolumes Btrfs
A criação de subvolumes separados para `/var/log` e `/var/cache` é uma **boa prática** para excluir dados voláteis dos snapshots, facilitando rollbacks.
```sh
# Monta o subvolume padrão (ID 5) para criar os outros
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvolid=5 /dev/sda3 /mnt

# Cria subvolumes essenciais
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache

# Desmonte
umount /mnt
```
---

# ▶️ 7. Montar subvolumes

1. montagem
```
# Monta o subvolume principal (@)
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@ /dev/sda3 /mnt

# Cria os pontos de montagem
mkdir -pv /mnt/{boot/efi,home,var/log,var/cache,.snapshots,swap}

# Monta os subvolumes restantes
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@home      /dev/sda3 /mnt/home
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@snapshots /dev/sda3 /mnt/.snapshots
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@log       /dev/sda3 /mnt/var/log
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@cache     /dev/sda3 /mnt/var/cache

# Monta a ESP/UEFI corretamente em /boot/efi
mount /dev/sda2 /mnt/boot/efi
```

2. verifique a montagem:
```
lsblk -f /dev/sda
```

3. Copia as chaves do repositório (XBPS keys) para o /mnt
```
mkdir -pv /mnt/{etc,var/db/xbps/keys}
cp -rpafv /var/db/xbps/keys/*.plist /mnt/var/db/xbps/keys/
cp -fpav /etc/resolv.conf /mnt/etc/resolv.conf
```
---

# ▶️ 8. Instalar o Void Linux
```
XBPS_ARCH=x86_64 \
xbps-install -Sy -R https://repo-default.voidlinux.org/current \
  -r /mnt base-system btrfs-progs grub grub-x86_64-efi \
  linux-headers linux-firmware-network dhcpcd nano grc zstd xz
```
---

# ▶️ 9. Entrar no sistema (chroot)
1. Montar os diretórios essenciais dentro do ambiente chroot:
```
for i in proc sys dev run; do mount --rbind /$i /mnt/$i; done
```
2. Entrar no chroot:
```
chroot /mnt /bin/bash
```
3. Definir um prompt visível dentro do chroot:
```
export PS1='(chroot)\[\033[1;32m\]\u\[\033[1;33m\]@\[\033[1;36m\]\h\[\033[1;31m\]:\w \
$( [[ $? -eq 0 ]] && printf "\033[1;32m✔" || printf "\033[1;31m✘\033[1;35m%d" $? ) \
\[\033[0m\]\$ '
```

# ▶️ 10. Configurações iniciais (no chroot)
1. Configurar hostname
Define o nome da máquina:
```
echo void > /etc/hostname
```

2. Configurar timezone
Define o fuso horário para America/Sao_Paulo:
```
ln -sfv /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
```

3. configure locales
Edite o arquivo de locales:
```
nano /etc/default/libc-locales
```
Descomente as seguintes linhas:
```
en_US.UTF-8 UTF-8
pt_BR.UTF-8 UTF-8
```

ou use o comando abaixo para fazer automaticamente:
```
sed -i -e 's/^#\(en_US.UTF-8 UTF-8\)/\1/' \
       -e 's/^#\(pt_BR.UTF-8 UTF-8\)/\1/' \
       /etc/default/libc-locales
```

4. Gere o locales:
```
xbps-reconfigure -f glibc-locales
```

5. Ativar alguns serviços:
```
ln -sfv /etc/sv/dhcpcd /var/service
ln -sfv /etc/sv/sshd /var/service
```

6. reconfigurar senha root:
```
passwd
```

# ▶️ 11. Criar swapfile com suporte a hibernação
1. Calcular automaticamente o tamanho ideal do swapfile
Recomendação moderna para hibernação: 60% da RAM total
```
SWAP_GB=$(LC_ALL=C awk '/MemTotal/ {print int($2 * 0.60 / 1024 / 1024)}' /proc/meminfo)
echo "Swapfile recomendado: ${SWAP_GB}G"
```

2. Criar diretório para o swapfile
```
mkdir -p /swap
swapoff -a 2>/dev/null
rm -f /swap/swapfile
```

3. Desabilitar COW (obrigatório no Btrfs)
```
chattr +C /swap
```

4. Criar o swapfile com o tamanho calculado
```
fallocate -l ${SWAP_GB}G /swap/swapfile
chmod 600 /swap/swapfile
```

5. Formatar o swapfile e ativar o swap
```
mkswap /swap/swapfile
swapon /swap/swapfile
```

6. Verificar:
```
swapon --show
```

### Observações importantes
- Swapfile em Btrfs sempre aparece como **prealloc**, é normal. 
- Não precisa ser do tamanho total da RAM. 
- 60% é suficiente para hibernação na maioria dos casos. 
- Para cargas pesadas → use 70% ou 80%.

7. Obter offset:
```
# Instala o pacote para o filefrag
xbps-install -Sy e2fsprogs

# Obtém o offset
offset=$(filefrag -v /swap/swapfile | awk '/^ *0:/{print $4}')
```

# Configurar o Kernel para Hibernação:
1. Obter o UUIDs das partições:
```
UUID=$(blkid -s UUID -o value /dev/sda3)
UUID_EFI=$(blkid -s UUID -o value /dev/sda2)
```

2. Configurar o GRUB com o UUID da partição e o offset do `swapfile`:
Edite o arquivo /etc/default/grub e adicione/modifique a linha:
```
echo "GRUB_CMDLINE_LINUX=\"resume=UUID=$UUID resume_offset=$offset\"" >> /etc/default/grub
```

3. Refazer o `initrd`
```
KVER=$(ls /usr/lib/modules); echo $KVER
dracut --force /boot/initramfs-${KVER}.img ${KVER}
```

4. Configurar montagem dos subvolumes no /etc/fstab
```
cat <<EOF >> /etc/fstab
# ======== BTRFS – Subvolumes ========
UUID=$UUID         /           btrfs defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=@           0 0
UUID=$UUID         /home       btrfs defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=@home       0 0
UUID=$UUID         /var/log    btrfs defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=@log        0 0
UUID=$UUID         /var/cache  btrfs defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=@cache      0 0
UUID=$UUID         /.snapshots btrfs defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=@snapshots  0 0
# ======== EFI System Partition ========
UUID=$UUID_EFI                                    /boot/efi   vfat  defaults,noatime,umask=0077                                      0 2
# ======== Swapfile ========
/swap/swapfile                                    none        swap  sw                                                               0 0
EOF
```
---

# ▶️ 12. Instalar GRUB em **BIOS** e **UEFI** (híbrido real)
1. Instalar GRUB para BIOS (Legacy)
Usa a partição BIOS criada como primeira.
```
grub-install --target=i386-pc /dev/sda
```
2. Instalar GRUB para UEFI
```
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Void
```
3. Criar fallback UEFI (boot universal)
Esse arquivo garante boot mesmo quando a NVRAM for apagada.
```
mkdir -p /boot/efi/EFI/BOOT
cp -vf /boot/efi/EFI/Void/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
```
4. Gerar arquivo final do GRUB
```
grub-mkconfig -o /boot/grub/grub.cfg
```

### ▶️ Alterar o shell padrão do usuário root para Bash
Por padrão, o Void Linux usa `/bin/sh` (dash) como shell mínimo.  
Para que o usuário **root** utilize o Bash ao fazer login (TTY/SSH), execute:
```
chsh -s /bin/bash root
```

Verifique se a alteração foi aplicada:
```
getent passwd root         # A última coluna deve mostrar: /bin/bash
```
Isso altera apenas o shell de login do root — o `/bin/sh` do sistema continua sendo gerenciado pelo Void.

### ▶️ Personalizar o .bashrc do root (opcional)
```
cat << 'EOF' > /root/.bash_profile
# ~/.bash_profile — carrega o .bashrc no Void

# Se o .bashrc existir, carregue
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
EOF

cat << 'EOF' > /root/.bashrc
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
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
# Segurança raiz (evita rm catastrófico)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ping='grc ping'
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

# ▶️ 13. Finalizar instalação
1. Sair do chroot e desmontar os bind mounts:
```
exit
for i in run dev sys proc; do umount -R /mnt/$i; done
umount -R /mnt
```
2. Reiniciar o sistema host:
```
reboot
```

---

## ▶️ 14. Ativar ZRAM (após o reboot no sistema instalado)
O Void Linux utiliza o serviço zramen para habilitar ZRAM, criando um bloco de memória comprimida que reduz o uso de swap no SSD e melhora o desempenho sob carga.
1. Instalar o zramen
```
xbps-install -Sy zramen
```
2. Configurar o ZRAM
```
nano /etc/zramen.conf
```
Configuração recomendada:
```
zram_fraction=0.5
zram_devices=1
zram_algorithm=zstd
```

3. Ativar o serviço no runit
```
ln -s /etc/sv/zramen /var/service
```

Verificar status:
```
sv status zramen
```
O ZRAM será ativado automaticamente em todos os boots

---
---


# 🎉 SISTEMA COMPLETO, HÍBRIDO E À PROVA DE FUTURO
- Boot BIOS + UEFI 
- Fallback UEFI 
- Btrfs com snapshots (pronto para Snapper/Timeshift) 
- Hibernação real com swapfile 
- Zram para performance 

Este SSD boota **em qualquer máquina do planeta**.

# DISCLAIMER

```
Este tutorial é livre: você pode usar, copiar, modificar e redistribuir como quiser.  
O conteúdo é disponibilizado sob a **Licença MIT**, e pode incluir trechos ou comandos derivados de softwares de código aberto sujeitos às suas próprias licenças.

Nenhuma garantia é fornecida — tudo aqui é entregue “no estado em que se encontra”.  
Use por sua conta e risco. Nem o autor, nem colaboradores, nem o Void Linux são responsáveis por perdas, danos, falhas de sistema ou qualquer consequência do uso deste material.

Se desejar, você pode obter o código-fonte, revisar, adaptar e gerar sua própria versão deste tutorial.
```

