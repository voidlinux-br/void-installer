# 🧩   TUTORIAL VOID LINUX + BTRFS + SUBVOLUMES + HIBERNAÇÃO + ZRAM  
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

# ▶️    1. Bootar o Live ISO

Use a versão glibc pela compatibilidade superior:
- baixe a iso em:
```
https://repo-default.voidlinux.org/live/current/void-live-x86_64-20250202-base.iso
```
- ou procure a última versão em:
```
https://voidlinux.org/download/
```

1. Entre como root.
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
export PS1='\[\e[1;32m\]\u\[\e[1;33m\]@\[\e[1;36m\]\h\[\e[1;31m\]:\w \
$([[ $? -eq 0 ]] && echo -e "\e[1;32m✔" || echo -e "\e[1;31m✘$?") \
\[\e[0m\]\$ '
```

# ▶️    2. Conectar à Internet
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
xbps-install -Sy xbps parted jfsutils xfsprogs nano zstd xz bash-completion
```
---

# ▶️    3. Identificar o disco
1. Listar os discos disponíveis e anotar o nome do dispositivo (ex: `/dev/sda`, `/dev/vda`, `/dev/nvme0n1`):
```
fdisk -l | grep -E '^(Disk|Disco) '
```
> Assumiremos para o tutorial `/dev/sda`

2. Altere abaixo, conforme o disco que será usado (IMPORTANTE):
```
DEVICE=/dev/sda
DEV_BIOS=/dev/sda1
DEV_EFI=/dev/sda2
DEV_RAIZ=/dev/sda3
```

---

# ▶️    4. Criar tabela GPT + Partições
- A partição BIOS **DEVE** ser a primeira.  
Isso aumenta compatibilidade com placas-mãe antigas, bootloaders problemáticos e BIOS que esperam o código de boot nas primeiras áreas do disco.  
A ESP pode vir depois sem problema algum — UEFI não liga para a posição.

### Ordem ideal e correta:

- 1️⃣ BIOS Boot (EF02)
- 2️⃣ ESP (EFI System, FAT32)
- 3️⃣ Btrfs/Ext4/Xfs/Jfs (raiz)

### Particione usando o parted (automatico)

```
parted --script ${DEVICE} -- \
    mklabel gpt \
    mkpart primary fat32 1MiB 2MiB set 1 bios on name 1 BIOS \
    mkpart primary fat32 2MiB 512MiB set 2 esp on name 2 EFI \
    mkpart primary btrfs 512MiB 100% name 3 ROOT \
    align-check optimal 1
parted --script ${DEVICE} -- print
```

---

# ▶️    5. Formatar as partições

Formate cada partição com o sistema de arquivos correto:
```
@ a ESP deve ser formatada sempre
mkfs.fat -F32 ${DEV_EFI} -n EFI
```
2. Escolha **APENAS UM** dos formatos abaixo para o sistema de arquivos raiz:
```
mkfs.btrfs -f ${DEV_RAIZ} -L ROOT       # - BTRFS (recomendado — subvolumes, snapshots, compressão)
mkfs.ext4 -F  ${DEV_RAIZ} -L ROOT       # - EXT4 (clássico, estável, simples)
mkfs.xfs -f   ${DEV_RAIZ} -L ROOT       # - XFS (alto desempenho, ótimo para SSD)
mkfs.jfs -q   ${DEV_RAIZ} -L ROOT       # - JFS (leve, baixo consumo de CPU)
```
3. Confirmar se tudo foi criado corretamente:
```
lsblk -f ${DEVICE}
```
---

# ▶️    6. Criar subvolumes Btrfs e montar - (Somente se a raiz for btrfs)

1. A criação de subvolumes separados para `/var/log` e `/var/cache` é uma **boa prática** para excluir dados voláteis dos snapshots, facilitando rollbacks.
```
# Monta o subvolume padrão (ID 5) para criar os outros
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvolid=5 ${DEV_RAIZ} /mnt

# Cria subvolumes essenciais
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache

# Desmonte
umount /mnt
```
2. Montar subvolumes - (Somente se a raiz for btrfs)
```
# Monta o subvolume principal (@)
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@ ${DEV_RAIZ} /mnt

# Cria os pontos de montagem
mkdir -pv /mnt/{boot/efi,home,var/log,var/cache,.snapshots,swap}

# Monta os subvolumes restantes
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@home      ${DEV_RAIZ} /mnt/home
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@cache     ${DEV_RAIZ} /mnt/var/cache
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@log       ${DEV_RAIZ} /mnt/var/log
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@snapshots ${DEV_RAIZ} /mnt/.snapshots

# Monta a ESP/UEFI corretamente em /boot/efi
mount -v ${DEV_EFI} /mnt/boot/efi
```

# ▶️    7. Montar partições EXT4/XFS/JFS  (se a raiz NÃO for BTRFS)
1. Montar diretamente a partição raiz:
```
mount -v ${DEV_RAIZ} /mnt
```
2. Cria os pontos de montagem
```
mkdir -pv /mnt/{boot/efi,swap}
```
4. Monta a ESP/UEFI corretamente em /boot/efi do chroot
```
mount -v ${DEV_EFI} /mnt/boot/efi
```
5. verifique a montagem:
```
lsblk -f ${DEVICE}
```
---

# ▶️    8. Instalar o Void Linux no chroot

1. Copie as chaves do repositório (XBPS keys) para ser usada no chroot (/mnt)
```
mkdir -pv /mnt/{etc,var/db/xbps/keys}
cp -rpafv /var/db/xbps/keys/*.plist /mnt/var/db/xbps/keys/
cp -fpav /etc/resolv.conf /mnt/etc/resolv.conf
```

2. Instale o sistema base no disco recém-montado:
```
xbps-install -Sy \
   -R https://repo-default.voidlinux.org/current \
   -r /mnt \
   base-system btrfs-progs grub grub-x86_64-efi \
   linux-headers linux-firmware-network dhcpcd \
   nano grc zstd xz bash-completion jfsutils xfsprogs \
   socklog-void wget net-tools tmate ncurses
```
---

# ▶️    9. Acessar o sistema instalado usando chroot

1. Entrar no chroot:
```
xchroot /mnt /bin/bash
```
2. Definir um prompt visível dentro do chroot (opcional):
```
export PS1='(chroot)\[\033[1;32m\]\u\[\033[1;33m\]@\[\033[1;36m\]\h\[\033[1;31m\]:\w \
$( [[ $? -eq 0 ]] && printf "\033[1;32m✔" || printf "\033[1;31m✘\033[1;35m%d" $? ) \
\[\033[0m\]\$ '
```
---

# ▶️    10. Configurações iniciais (no chroot)
1. Configurar hostname
```
# define o nome da máquina:
echo void > /etc/hostname
```

2. Configurar timezone
```
# define o fuso horário para America/Sao_Paulo, altere se necessário:
ln -sfv /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
```

3. configure locales
```
sed -i -e 's/^#\(en_US.UTF-8 UTF-8\)/\1/' \
       -e 's/^#\(pt_BR.UTF-8 UTF-8\)/\1/' \
       /etc/default/libc-locales
```

4. Gere o locales:
```
xbps-reconfigure -f glibc-locales
```

5. Corrigir possível erro no symlink do /var/service (importante):
```
rm -f /var/service
ln -sf /etc/runit/runsvdir/default /var/service
```

6. Ativar alguns serviços:
```
ln -sf /etc/sv/dhcpcd /var/service/
ln -sf /etc/sv/sshd /var/service/
ln -sf /etc/sv/nanoklogd /var/service/
ln -sf /etc/sv/socklog-unix /var/service/
```

7. Criar usuário
```
NEWUSER=seunomeaqui
useradd -m -G audio,video,wheel,tty -s /bin/bash ${NEWUSER}
passwd ${NEWUSER}
```

8. reconfigurar senha root (importante):
```
passwd root
```
---

# ▶️    11. Criar swapfile com suporte a hibernação (opcional)

### Observações importantes
```
- Swapfile em Btrfs sempre aparece como **prealloc**, é normal. 
- Não precisa ser do tamanho total da RAM. 
- 60% é suficiente para hibernação na maioria dos casos. 
- Para cargas pesadas → use 70% ou 80%.
```

1. Calcular automaticamente o tamanho ideal do swapfile
```
# recomendação moderna para hibernação: 60% da RAM total
SWAP_GB=$(LC_ALL=C awk '/MemTotal/ {print int($2 * 0.60 / 1024 / 1024)}' /proc/meminfo)
echo "Swapfile recomendado: ${SWAP_GB}G"
```
- ou, defina manualmente o tamanho desejado:
```
SWAP_GB=4
echo "Swapfile definido pelo usuario: ${SWAP_GB}G"
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

4. Criar o swapfile com o tamanho definido anteriormente
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

7. Obter offset:
```
# Instala o pacote para o filefrag
xbps-install -Sy e2fsprogs

# Obtém o offset
offset=$(filefrag -v /swap/swapfile | awk '/^ *0:/{print $4}')
```

---

# ▶️    12. Configurar UUIDs

- Obter o UUIDs das partições (importante):
```
UUID=$(blkid -s UUID -o value ${DEV_RAIZ})
UUID_EFI=$(blkid -s UUID -o value ${DEV_EFI})
```
---

# ▶️    13. Configurar o Kernel para hibernação (opcional)
Configurar o GRUB com o UUID da partição e o offset do `swapfile`
```
#adicione a linha abaixo no arquivo /etc/default/grub
echo "GRUB_CMDLINE_LINUX=\"resume=UUID=$UUID resume_offset=$offset\"" >> /etc/default/grub
```
---

# ▶️    14. Recriar o initrd

```
mods=(/usr/lib/modules/*)
KVER=$(basename "${mods[0]}")
echo ${KVER}
dracut --force --kver ${KVER}
```
---

# ▶️    15. Configurar montagem das partições no /etc/fstab

> Não esquecer de configurar passo 12

1. Se a raiz for **BTRFS**
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
/swap/swapfile                                    none        swap  sw,nofail                                                        0 0
EOF
```
2. Se a raiz for **EXT4**
```
cat <<EOF >> /etc/fstab
# ======== EXT4 ========
UUID=$UUID         /           ext4  defaults,noatime,discard=async  0 1
# ======== EFI System Partition ========
UUID=$UUID_EFI                                    /boot/efi   vfat  defaults,noatime,umask=0077     0 2
# ======== Swapfile ========
/swap/swapfile                                    none        swap  sw,nofail                       0 0
EOF
```

3. Se a raiz for **XFS**
```
cat <<EOF >> /etc/fstab
# ======== XFS ========
UUID=$UUID         /           xfs   rw,noatime,attr2,logbufs=8   0 1
# ======== EFI System Partition ========
UUID=$UUID_EFI                                    /boot/efi   vfat  defaults,noatime,umask=0077  0 2
# ======== Swapfile ========
/swap/swapfile                                    none        swap  sw,nofail                    0 0
EOF
```
4. Se a raiz for **JFS**
```
cat <<EOF >> /etc/fstab
# ======== JFS ========
UUID=$UUID         /           jfs   defaults,noatime             0 1
# ======== EFI System Partition ========
UUID=$UUID_EFI                                    /boot/efi   vfat  defaults,noatime,umask=0077  0 2
# ======== Swapfile ========
/swap/swapfile                                    none        swap  sw,nofail                    0 0
EOF
```
---

# ▶️    16. Instalar GRUB em **BIOS** e **UEFI** (híbrido real)
1. Instalar GRUB para BIOS (Legacy)
```
grub-install --target=i386-pc ${DEVICE}
```
2. Instalar GRUB para UEFI
```
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=void --recheck
```
3. Criar fallback UEFI (boot universal). Esse arquivo garante boot mesmo quando a NVRAM for apagada.
```
mkdir -p /boot/efi/EFI/BOOT
cp -vf /boot/efi/EFI/void/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
```
4. Gerar arquivo final do GRUB
```
grub-mkconfig -o /boot/grub/grub.cfg
```

---

# ▶️    17. Configurações customizadas dos usuários:

1. Alterar o shell padrão do usuário root para Bash
```
chsh -s /bin/bash root
```
2. Personalizar o /etc/xbps.d/00-repository-main.conf
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

3. Personalizar o /etc/rc.conf. Define o fuso horário, layout do teclado e fonte padrão do console. Altere conforme necessidade.
```
cat << 'EOF' >> /etc/rc.conf
TIMEZONE=America/Sao_Paulo
KEYMAP=br-abnt2
FONT=Lat2-Terminus16
EOF
```

4. Personalizar o .bashrc do root
> confira se criou o usuário no passo anterior
```
wget --quiet --no-check-certificate \
   -O /etc//skel/.bashrc \
   "https://raw.githubusercontent.com/voidlinux-br/void-installer/refs/heads/main/.bashrc"
chown root:root /etc/skel/.bashrc
chmod 644 /etc/skel/.bashrc
```

```
cat << 'EOF' > /etc/skel/.bash_profile
# ~/.bash_profile — carrega o .bashrc no Void

# Se o .bashrc existir, carregue
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
EOF
```

```
# copia para o root e usuario
for d in /root "/home/${NEWUSER}"; do
   cp -f /etc/skel/.bash_profile "$d/"
   cp -f /etc/skel/.bashrc "$d/"
done

chown "${NEWUSER}:${NEWUSER}" "/home/${NEWUSER}/.bash_profile" "/home/${NEWUSER}/.bashrc"
chmod 644 "/home/${NEWUSER}/.bash_profile" "/home/${NEWUSER}/.bashrc"
```

5. baixar svlogtail customizado
```
wget --quiet --no-check-certificate \
  -O /usr/bin/svlogtail \
  "https://raw.githubusercontent.com/voidlinux-br/void-installer/refs/heads/main/svlogtail"
chmod +x /usr/bin/svlogtail
```

---

# ▶️    21. Ativar ZRAM (opcional)
O Void Linux utiliza o serviço zramen para habilitar ZRAM, criando um bloco de memória comprimida que reduz o uso de swap no SSD e melhora o desempenho sob carga.
1. Instalar o zramen
```
xbps-install -Sy zramen
```
2. Configurar o ZRAM (configuração recomendada):
```
cat << 'EOF' > /etc/zramen.conf
zram_fraction=0.5
zram_devices=1
zram_algorithm=zstd
EOF
```
3. Ativar o serviço no runit
```
ln -s /etc/sv/zramen /var/service/
```
4. Verificar status:
```
sv status zramen
```
> O ZRAM será ativado automaticamente em todos os boots

---

# ▶️    22. Finalizar instalação
1. Sair do chroot:
```
exit
```
2. Desmonta todas as partições montadas em /mnt (subvolumes e /boot/efi):
```
umount -R /mnt
```
3. Desativa qualquer swapfile ou swap partition que tenha sido ativada dentro do chroot:
```
swapoff -a
```
4. Reinicia a máquina física ou a VM para testar o boot real:
```
reboot
```
> Não esqueça de remover a mídia de instalação e dar boot pelo disco recém-instalado.  
Enjoy!

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

