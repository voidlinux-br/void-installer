# 🧩 TUTORIAL VOID LINUX — INSTALAÇÃO HÍBRIDA (UEFI + BIOS) COM EXT4, XFS, JFS OU BTRFS (SUBVOLUMES), LUKS, HIBERNAÇÃO E ZRAM
### VERSÃO REVISADA E VALIDADA — PARTICIONAMENTO CORRETO + BOOT UNIVERSAL

Este guia instala um Void Linux totalmente **híbrido**, capaz de dar boot em qualquer tipo de máquina — antiga, nova ou problemática:

- 💾 **UEFI moderno** (com entrada normal e fallback)
- 🧮 **BIOS/Legacy** (compatibilidade total)
- 🧰 **GPT com BIOS Boot (EF02)** — máximo suporte a hardware antigo
- 🚀 **Btrfs com subvolumes** (opcional), snapshots prontos
- 🔐 **LUKS1 totalmente compatível com GRUB**
- 🌙 **Hibernação real via swapfile**
- 🧊 **ZRAM configurado para desempenho**
- 🧱 **Suporte completo a EXT4, XFS, JFS e BTRFS**
- 💡 **Initramfs/GRUB configurados automaticamente (LUKS + resume)**

📌 **Sem gambiarra, sem reinstalar GRUB, sem perder tempo.**  
📌 **Boot garantido até em máquina com NVRAM apagada (fallback BOOTX64.EFI).**

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
fdisk -l
```
2. Definir os devices (ANTES de usar qualquer um)
> Ajusta aqui conforme o teu disco.  
Exemplo abaixo: /dev/sda com 3 partições (BIOS, EFI, ROOT):
```
export DEVICE=/dev/sda
export DEV_BIOS=/dev/sda1
export DEV_EFI=/dev/sda2
export DEV_RAIZ=/dev/sda3
export DEV_LUKS=/dev/mapper/cryptroot
```
- DEVICE → disco inteiro  
- DEV_BIOS → partição BIOS boot (1–2 MiB, sem FS, não monta)  
- DEV_EFI → partição EFI (FAT32)  
- DEV_RAIZ → partição raiz (normal ou LUKS)  
- DEV_LUKS → mapeamento do LUKS (/dev/mapper/cryptroot)  

> Assumiremos para o tutorial `/dev/sda`

- 🔎   Por que isso é necessário?  
Porque declarar tudo no início deixa o processo à prova de erro.   
Em outras palavras:  
- 👉   Aqui você define a anatomia do disco. Todo o resto do guia apenas segue essas variáveis.
---

# ▶️    4. Particionar usando o parted (automático)
- A partição BIOS **DEVE** ser a primeira.  
Isso aumenta compatibilidade com placas-mãe antigas, bootloaders problemáticos e BIOS que esperam o código de boot nas primeiras áreas do disco.  
A ESP pode vir depois sem problema algum — UEFI não liga para a posição.

### Ordem ideal e correta:

- 1️⃣ BIOS Boot (EF02)
- 2️⃣ ESP (EFI System, FAT32)
- 3️⃣ Btrfs/Ext4/Xfs/Jfs (raiz)

### Particione usando o parted (automatico)
> Aqui o DEVICE já está definido lá em cima, então não tem variável “mágica”.
```
parted --script "${DEVICE}" -- \
  mklabel gpt \
  mkpart primary 1MiB 2MiB name 1 BIOS set 1 bios_grub on \
  mkpart primary fat32 2MiB 514MiB name 2 EFI set 2 esp on \
  mkpart primary 514MiB 100% name 3 ROOT \
  align-check optimal 1

parted --script "${DEVICE}" -- print
```
- Partição 1 → BIOS boot (bios_grub, sem FS, não monta)  
- Partição 2 → EFI (FAT32)  
- Partição 3 → ROOT (vamos formatar depois com EXT4/XFS/JFS/BTRFS, com ou sem LUKS)  
Usei mkpart primary 514MiB 100% sem especificar FS justamente pra não amarrar o FS. Tu escolhe o FS depois.
---

# ▶️    5. Escolher o modo de instalação (NORMAL ou LUKS)
⚠️    **IMPORTANTE:**
> Escolha APENAS UM dos dois blocos abaixo.  
**NÃO** é pra rodar os dois.

1. INSTALAÇÃO NORMAL **(sem LUKS)**
```
# Remove qualquer assinatura antiga da partição raiz (FS/LUKS/etc)
wipefs -a "${DEV_RAIZ}"

DISK="${DEV_RAIZ}"
```
- Apaga assinaturas antigas da partição raiz  
- Define DISK como o dispositivo real /dev/sda3

2. INSTALAÇÃO **COM LUKS** (root criptografado)
```
# Remove qualquer assinatura antiga da partição raiz (FS/LUKS/etc)
wipefs -a "${DEV_RAIZ}"

# Criptografar SOMENTE a partição raiz em LUKS1 (compatível com GRUB) - nunca o disco inteiro
# Criptografar a partição confirmando com YES:  
cryptsetup luksFormat --type luks1 "${DEV_RAIZ}"

# Abra a partição com sua passphrase.
cryptsetup open "${DEV_RAIZ}" cryptroot

# A partir de agora, o root real é o dispositivo mapeado
DISK="${DEV_LUKS}"
```
- O LUKS fica em cima de /dev/sda3, não do disco inteiro  
- O sistema vai ser instalado em /dev/mapper/cryptroot

👉 A partir daqui, TUDO usa $DISK.

---

# ▶️    6. Criar o sistema de arquivos (FS) e montar root
⚠️    **IMPORTANTE:**
> Escolha APENAS UM dos dois blocos abaixo.  

1. **EXT4**
```
mkfs.ext4 -F "${DISK}" -L ROOT
mount "${DISK}" /mnt
```
2. **XFS**
```
mkfs.xfs -f "${DISK}"
mount "${DISK}" /mnt
```
3. **JFS**
```
mkfs.jfs -f "${DISK}"
mount "${DISK}" /mnt
```
4. **BTRFS simples**
```
mkfs.btrfs -f "${DISK}" -L ROOT
mount "${DISK}" /mnt
```
5. **BTRFS com subvolumes**
```
mkfs.btrfs -f "${DISK}" -L ROOT

mount ${DISK} /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@snapshots
umount /mnt

mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@ ${DISK} /mnt
mkdir -p /mnt/{boot/efi,home,var/log,var/cache,.snapshots,swap}

mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@home      ${DISK} /mnt/home
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@cache     ${DISK} /mnt/var/cache
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@log       ${DISK} /mnt/var/log
mount -o defaults,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,commit=300,subvol=/@snapshots ${DISK} /mnt/.snapshots
```
---

# ▶️    7. Preparar e montar a ESP (EFI)
```
mkfs.fat -F32 "${DEV_EFI}"
mkdir -p /mnt/boot/efi
mount "${DEV_EFI}" /mnt/boot/efi
```
>💡   A partição BIOS (${DEV_BIOS}) não tem sistema de arquivos, não formata, não monta.
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
xbps-install -Sy -R https://repo-default.voidlinux.org/current \
   -r /mnt \
   base-system btrfs-progs cryptsetup grub grub-x86_64-efi dracut linux \
   linux-headers linux-firmware linux-firmware-network glibc-locales \
   xtools dhcpcd openssh vim nano grc zstd xz bash-completion vpm vsv \
   socklog-void wget net-tools tmate ncurses jfsutils xfsprogs
```
---

# ▶️    9. Criar fstab
```
xgenfstab -U /mnt > /mnt/etc/fstab
```

# ▶️    9. Acessar o sistema instalado usando chroot

1. Entrar no chroot:
```
xchroot /mnt /bin/bash
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

# ▶️    11. Configurar UUIDs

- Obter o UUIDs das partições (importante):
```
UUID_LUKS=$(blkid -s UUID -o value "${DEV_RAIZ}")
UUID_ROOT=$(blkid -s UUID -o value "${DISK}")
UUID_EFI=$(blkid -s UUID -o value "${DEV_EFI}")
```
---

# ▶️    12. Criar swapfile com suporte a hibernação (opcional)

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

# ▶️    13. Configurar o GRUB (automático: LUKS e/ou Hibernação)
⚠️    **IMPORTANTE:**
> Este bloco é inteligente:  
- Detecta automaticamente se você está usando LUKS  
- Detecta se você criou swapfile com hibernação  
- Ajusta o /etc/default/grub sem duplicar nada  
- Cria as linhas necessárias somente se faltarem  
- Não altera nada se não for preciso  

Use exatamente o bloco abaixo:
```
# ===========================
# Ajustes automáticos do GRUB
# ===========================
HAS_LUKS=0
HAS_RESUME=0

# Detecta LUKS
if [ "${DISK}" = "${DEV_LUKS}" ]; then
   HAS_LUKS=1
   grep -q '^GRUB_ENABLE_CRYPTODISK=y' /etc/default/grub || \
      echo 'GRUB_ENABLE_CRYPTODISK=y' >> /etc/default/grub
fi

# Detecta hibernação
[ -n "${offset}" ] && HAS_RESUME=1

# Se não precisa de nada, sai
if [ $HAS_LUKS -eq 0 ] && [ $HAS_RESUME -eq 0 ]; then
   echo "GRUB: nenhuma modificação necessária."
   return
fi

# Constroi a linha que PRECISA existir
NEEDED=""
[ $HAS_LUKS -eq 1 ] && NEEDED="${NEEDED} cryptdevice=UUID=${UUID_LUKS}:cryptroot"
[ $HAS_RESUME -eq 1 ] && NEEDED="${NEEDED} resume=UUID=${UUID_ROOT} resume_offset=${offset}"
NEEDED="${NEEDED# }"   # remove espaços iniciais

# --- SED INTELIGENTE ---
sed -i '
/^GRUB_CMDLINE_LINUX=/ {
  /cryptdevice=/! s/"$/ cryptdevice=UUID='"${UUID_LUKS}"':cryptroot"/
  /resume=/! s/"$/ resume=UUID='"${UUID_ROOT}"' resume_offset='"${offset}"'"/
  b
}
$ a GRUB_CMDLINE_LINUX="'"${NEEDED}"'"
' /etc/default/grub
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

# ▶️    15. Criar Keyfile para evitar pedir senha duas vezes (somente LUKS)
> Se o sistema NÃO usa LUKS, pule este passo.
```
if [ "${DISK}" = "${DEV_LUKS}" ]; then
  echo "LUKS detectado: criando keyfile para desbloqueio automático..."

  # Criar keyfile seguro
  dd if=/dev/urandom of=/boot/volume.key bs=64 count=1
  chmod 000 /boot/volume.key

  # Adicionar keyfile ao LUKS (pedirá sua senha atual)
  cryptsetup luksAddKey "${DEV_RAIZ}" /boot/volume.key

  # Configurar /etc/crypttab
  cat << EOF >> /etc/crypttab
cryptroot ${DEV_RAIZ} /boot/volume.key  luks
EOF

   # Incluir keyfile e crypttab no initramfs
   mkdir -p /etc/dracut.conf.d
   cat << EOF >> /etc/dracut.conf.d/10-crypt.conf
install_items+=" /boot/volume.key /etc/crypttab "
EOF

   # Regenerar initramfs com suporte ao keyfile
   xbps-reconfigure -fa
else
   echo "Sistema sem LUKS: pulando criação de keyfile."
fi
```

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

# ▶️    18. Ativar ZRAM (opcional)
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

# ▶️    19. Finalizar instalação
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

