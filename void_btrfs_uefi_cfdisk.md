# 🔥 Instalação do Void Linux com Btrfs + Subvolumes + Swapfile + UEFI (Guia Completo)
(Somente UEFI, sem BIOS/Legacy)

## Iniciar a Instalação
Inicie pelo ISO do Void Linux (x86_64 glibc ou musl).

- Entre como root.
```
login    : root
password : voidlinux
```

2. Troque o layout de teclado para ABNT2
```bash
loadkeys br-abnt2
```

3. Identificar o disco
```bash
fdisk -l
```

4. Abrir o cfdisk
```bash
cfdisk -z /dev/sda
```

Selecione **GPT**.

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

## Criar subvolumes

### Monte o dispositivo cryptroot em /mnt e crie nele seus subvolumes. (`@swap` foi adicionado para o `swapfile`):
```bash
mount /dev/mapper/cryptroot /mnt
```
```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@boot
```

### Desmonte o dispositivo:
```bash
umount /mnt
```

## Montar os subvolumes do sda2/cryptroot no /mnt:

### O subvolume principal (@)
```bash
mount -o subvol=@,compress=zstd:3 /dev/mapper/cryptroot /mnt
```

### Cria os pontos de montagem (incluindo os do chroot)
```bash
mkdir -p /mnt/{home,boot,var/log,var/cache,.snapshots,swap}

```
```bash
mkdir -p /mnt/{dev,proc,sys,run}
```

### Monta os subvolumes restantes
```bash
mount -o subvol=@home,compress=zstd:3 /dev/mapper/cryptroot /mnt/home
mount -o subvol=@log /dev/mapper/cryptroot /mnt/var/log
mount -o subvol=@cache /dev/mapper/cryptroot /mnt/var/cache
mount -o subvol=@snapshots,compress=zstd:3 /dev/mapper/cryptroot /mnt/.snapshots
mount -o subvol=@swap /dev/mapper/cryptroot /mnt/swap
```

### A ESP, em /dev/sda1 vai ser montado em /mnt/boot/efi

## Monte /boot:

```bash
mount -o subvol=@boot /dev/mapper/cryptroot /mnt/boot
```

## ❗ ATENÇÃO – Diretório /mnt/boot/efi SOME após montar /mnt/boot

## Recrie ele:

```bash
mkdir -p /mnt/boot/efi
```

## Agora sim, monte EFI:

```bash
mount /dev/sda1 /mnt/boot/efi
```

## Instalar o sistema base
```
xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt base-system btrfs-progs cryptsetup grub-x86_64-efi dracut linux linux-firmware linux-firmware-network glibc-locales xtools vim
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
```

## Entrar no sistema (chroot)

```bash
for i in /dev /proc /sys /run; do mount --rbind $i /mnt$i; done
```

```bash
chroot /mnt /bin/bash
```

## Configurar GRUB

## Vamos validar a UUID da partição sda2:

```bash
blkid /dev/sda2
```

## Você receberá um UUID no modelo deste:

```bash
31c87e1e-dd47-4ed7-bd0c-780aa52cd1ea
```

## Que vamos apontar no arquivo do grub

```bash
vim /etc/default/grub
```

## Adicione/edite as linhas:

```bash
GRUB_ENABLE_CRYPTODISK=y
```

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.luks.uuid=31c87e1e-dd47-4ed7-bd0c-780aa52cd1ea rd.luks.name=31c87e1e-dd47-4ed7-bd0c-780aa52cd1ea=cryptroot root=/dev/mapper/cryptroot"
```

## Crie o path para suportar o grub

```bash
mkdir -p /boot/grub
```

## Gere o novo grub.cfg

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

## GRUB (UEFI)

## Instale o novo Grub:

```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="VoidLinux" --recheck
```

## Gerando o INITRAMFS

## Descubra versão do kernel:

```bash
ls /lib/modules
```

## Geralmente algo como: 6.12.58_1. Então:

```bash
dracut --kver 6.12.58_1 --force
```

## Criar um resolv.conf
```bash
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
```

## Configurações básicas

## Setar Hostname
```bash
echo void > /etc/hostname
```

## Setar Localtime
```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
```

## Setar Locales
```bash
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/default/libc-locales
sed -i 's/#pt_BR.UTF-8/pt_BR.UTF-8/' /etc/default/libc-locales
```

## Gerar locales:
```sh
xbps-reconfigure -f glibc-locales
```

## Trocar senha de root:
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
