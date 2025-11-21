# 🧩 TUTORIAL VOID LINUX + BTRFS + SUBVOLUMES + HIBERNAÇÃO + ZRAM  
### VERSÃO COMENTADA — SISTEMA HÍBRIDO (UEFI + BIOS) — COM ORDEM CORRETA DAS PARTIÇÕES

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
void-live-x86_64-BASE.iso
```

Entre como root.

---

# ▶️ 2. Conectar à Internet

Wi-Fi:

```sh
wpa_passphrase "SSID" "SENHA" > wifi.conf
wpa_supplicant -B -i wlan0 -c wifi.conf
dhcpcd wlan0
```

---

# ▶️ 3. Identificar o disco

```sh
fdisk -l
```

Assumiremos **/dev/sda**.

---

# ▶️ 4. Criar tabela GPT + Partições (ORDEM CORRETA)

**Explicação:**  
A partição BIOS **DEVE** ser a primeira.  
Isso aumenta compatibilidade com placas-mãe antigas, bootloaders problemáticos e BIOS que esperam o código de boot nas primeiras áreas do disco.

A ESP pode vir depois sem problema algum — UEFI não liga para a posição.

### Ordem ideal:
1️⃣ BIOS Boot (EF02)  
2️⃣ ESP (EFI System, FAT32)  
3️⃣ Btrfs (raiz)

---

### Criar as partições:

```sh
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

```sh
mkfs.fat -F32 /dev/sda2     # ESP (2ª partição)
mkfs.btrfs -f /dev/sda3     # Btrfs (3ª partição)
```

---

# ▶️ 6. Criar subvolumes Btrfs

```sh
mount -o subvolid=5 /dev/sda3 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_cache
umount /mnt
```

---

# ▶️ 7. Montar subvolumes

```sh
mount -o noatime,compress=zstd,space_cache=v2,subvol=@ /dev/sda3 /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache,.snapshots}
```

```sh
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home      /dev/sda3 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots /dev/sda3 /mnt/.snapshots
mount -o noatime,nodatacow,space_cache=v2,subvol=@var_log       /dev/sda3 /mnt/var/log
mount -o noatime,nodatacow,space_cache=v2,subvol=@var_cache     /dev/sda3 /mnt/var/cache
mount /dev/sda2 /mnt/boot     # monta a ESP
```

---

# ▶️ 8. Instalar o Void Linux

```sh
XBPS_ARCH=x86_64 \
xbps-install -Sy -R https://repo-default.voidlinux.org/current \
  -r /mnt base-system btrfs-progs grub-x86_64-efi linux-firmware-network
```

---

# ▶️ 9. Entrar no sistema (chroot)

```sh
for i in proc sys dev run; do mount --rbind /$i /mnt/$i; done
chroot /mnt /bin/bash
```

---

# ▶️ 10. Configurações iniciais

```sh
echo void > /etc/hostname
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
vi /etc/default/libc-locales
```

Descomente:

```
en_US.UTF-8 UTF-8
pt_BR.UTF-8 UTF-8
```

Gerar locales:

```sh
xbps-reconfigure -f glibc-locales
passwd
```

---

# ▶️ 11. Criar swapfile com suporte a hibernação

```sh
truncate -s 16G /swapfile
chattr +C /swapfile
btrfs property set /swapfile compression none
chmod 600 /swapfile
mkswap /swapfile
```

Adicionar ao fstab:

```
/swapfile none swap sw 0 0
```

Obter offset:

```sh
offset=$(filefrag -v /swapfile | awk '/^ *0:/{print $4}')
```

Configurar GRUB:

```
GRUB_CMDLINE_LINUX="resume=UUID=<uuid> resume_offset=<offset>"
```

Ativar suporte:

```sh
xbps-install resume
mkinitrd -f
```

---

# ▶️ 12. Instalar GRUB em **BIOS** e **UEFI** (híbrido real)

## 🔵 12.1 Instalar GRUB para BIOS (Legacy)
Usa a partição EF02 criada como primeira.

```sh
grub-install --target=i386-pc /dev/sda
```

## 🟢 12.2 Instalar GRUB para UEFI

```sh
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Void
```

## 🟣 12.3 Criar fallback UEFI (boot universal)

```sh
mkdir -p /boot/EFI/BOOT
cp /boot/EFI/Void/grubx64.efi /boot/EFI/BOOT/BOOTX64.EFI
```

Esse arquivo garante boot mesmo quando a NVRAM for apagada.

## 📝 12.4 Gerar arquivo final do GRUB

```sh
grub-mkconfig -o /boot/grub/grub.cfg
```

---

# ▶️ 13. Finalizar instalação

```sh
exit
for i in run dev sys proc; do umount -R /mnt/$i; done
umount -R /mnt
reboot
```

---

# ▶️ 14. Ativar ZRAM

```sh
xbps-install zramen
nano /etc/zramen.conf
```

```
zram_fraction=0.5
zram_devices=1
zram_algorithm=zstd
```

```sh
ln -s /etc/sv/zramen /var/service
```

---

# 🎉 SISTEMA COMPLETO, HÍBRIDO E À PROVA DE FUTURO
- Boot BIOS + UEFI  
- Fallback UEFI  
- Btrfs com snapshots  
- Hibernação real com swapfile  
- Zram para performance  

Este SSD boota **em qualquer máquina do planeta**.
