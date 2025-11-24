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

## Particionar o disco
1. Identificar o disco
```bash
fdisk -l
```
2. Abrir o cfdisk
```bash
cfdisk -z /dev/sda
```
Selecione **GPT**

- **ESP** — EFI System Partition — 512MB — tipo *EFI System*
- **Sistema (Btrfs)** — resto do disco — tipo *Linux filesystem*

> Salve e saia.

## Formatar partições

```bash
# Criptografar a partição raiz em LUKS1 (compatível com GRUB)
# Criptografar partição Btrfs Confirmando com YES:  
cryptsetup luksFormat --type luks1 /dev/sda2

# Abra a partição com sua passphrase. Será montada e mapeada, escolha um nome qualquer, aqui escolheremos cryptroot:
cryptsetup open /dev/sda2 cryptroot

# Formatar como Btrfs o dispositivo montado pelo cryptsetup no /dev/mapper, com o nome que setamos cryptroot:
mkfs.btrfs /dev/mapper/cryptroot

# Formatar ESP:
mkfs.fat -F32 /dev/sda1
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
mount /dev/sda1 /mnt/boot/efi
```

## Instalar o sistema base
```
xbps-install -Sy -R https://repo-default.voidlinux.org/current \
   -r /mnt \
   base-system btrfs-progs cryptsetup grub-x86_64-efi dracut linux \
   linux-headers linux-firmware linux-firmware-network glibc-locales xtools \
   dhcpcd vim nano grc zstd xz bash-completion
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
UUID=$(blkid -s UUID -o value /dev/sda2)
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

## Criar um resolv.conf
```bash
printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf
```

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
ln -sf /etc/sv/dhcpcd /var/service
ln -sf /etc/sv/sshd /var/service
```

## Trocar senha de root (importante):
```bash
passwd
```

## Criar swapfile em Btrfs (modo correto)
```
btrfs filesystem mkswapfile --size 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab
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
# Reinicia a máquina física ou a VM para testar o boot real
reboot
```

---

# 🎉 Fim!
O Void Linux agora está instalado com:

- 🔐 LUKS  
- 🗂️ Btrfs + subvolumes  
- 📁 swapfile dentro do Btrfs (seguro)  
- ⚙️ Boot UEFI limpo  
