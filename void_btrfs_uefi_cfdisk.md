# 🔥   Tutorial de instalação do Void Linux com Btrfs + Subvolumes + Swapfile + UEFI (Guia Completo)
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
# Criptografar partição Btrfs Confirmando com YES:  
cryptsetup luksFormat /dev/sda2

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
mount -o subvol=@,compress=zstd:3 /dev/mapper/cryptroot /mnt

# Cria os pontos de montagem (incluindo os do chroot)
mkdir -p /mnt/{home,boot/efi,var/log,var/cache,.snapshots,dev,proc,sys,run}

# Monta os subvolumes restantes
mount -o subvol=@home,compress=zstd:3 /dev/mapper/cryptroot /mnt/home
mount -o subvol=@log /dev/mapper/cryptroot /mnt/var/log
mount -o subvol=@cache /dev/mapper/cryptroot /mnt/var/cache
mount -o subvol=@snapshots,compress=zstd:3 /dev/mapper/cryptroot /mnt/.snapshots

# monte EFI:
mount -o umask=0077 /dev/sda1 /mnt/boot/efi
```

## Instalar o sistema base
```
xbps-install -Sy -R https://repo-default.voidlinux.org/current \
   -r /mnt \
   base-system btrfs-progs cryptsetup grub-x86_64-efi dracut linux \
   linux-firmware linux-firmware-network glibc-locales xtools vim \
   nano dhcpcd
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
1. Montar os diretórios essenciais dentro do ambiente chroot:
```
for i in /dev /proc /sys /run; do mount --rbind $i /mnt$i; done
```
2. Entrar no chroot:
```
chroot /mnt /bin/bash
```

## Configurar GRUB
```bash
# Pegar a UUID da partição sda2:
UUID=$(blkid -s UUID -o value /dev/sda2)

# Adicionando ao /etc/default/grub
cat << 'EOF' >> /etc/default/grub
GRUB_ENABLE_CRYPTODISK=y
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.luks.uuid=${UUID} rd.luks.name=${UUID}=cryptroot root=/dev/mapper/cryptroot"
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
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="VoidLinux" --recheck
```

## Gerando o INITRAMFS
```
mods=(/usr/lib/modules/*)
KVER=$(basename "${mods[0]}")
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

## Sair do chroot e reboot
```
exit
umount -R /mnt
swapoff -a
cryptsetup close cryptroot
reboot
```

---

# 🎉 Fim!
O Void Linux agora está instalado com:

- 🔐 LUKS2  
- 🗂️ Btrfs + subvolumes  
- 📁 swapfile dentro do Btrfs (seguro)  
- ⚙️ Boot UEFI limpo  
