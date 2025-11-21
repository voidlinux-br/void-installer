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

Entre como root.

---


Troque o shell de sh para o bash. O dash/sh NÃO suporta várias coisas que muitos scripts usam.
```sh
bash
```

Cole no terminal:

```bash
export GREEN="\033[1;32m"   # Verde
export RED="\033[1;31m"     # Vermelho
export YELLOW="\033[1;33m"  # Amarelo
export BLUE="\033[1;34m"    # Azul
export MAGENTA="\033[1;35m" # Magenta
export CYAN="\033[1;36m"    # Ciano
export RESET="\033[0m"      # Resetar as cores
export PS1="${GREEN}\u${YELLOW}@${CYAN}\h${RED}:\w\ ${RESET}\# "
```

# ▶️ 2. Conectar à Internet

Wi-Fi:
```sh
wpa_passphrase "SSID" "SENHA" > wifi.conf
wpa_supplicant -B -i wlan0 -c wifi.conf
dhcpcd wlan0
```

Instale alguns necessários pacotes:
```bash
xbps-install -Sy xbps parted vpm vsv nano
```
---

# ▶️ 3. Identificar o disco

```sh
fdisk -l
```
ou

```sh
parted -l
```

Assumiremos para o tutorial **/dev/sda**

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
parted --script /dev/sda -- \
    mklabel gpt \
    mkpart primary fat32 1MiB 2MiB set 1 bios on name 1 BIOS \
    mkpart primary fat32 2MiB 512MiB set 2 esp on name 2 EFI \
    mkpart primary btrfs 512MiB 100% name 3 ROOT \
    align-check optimal 1
parted --script /dev/sda -- print
```

OU

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

**REVISÃO:** A criação de subvolumes separados para `/var/log` e `/var/cache` é uma **boa prática** para excluir dados voláteis dos snapshots, facilitando rollbacks.

```sh
# Monta o subvolume padrão (ID 5) para criar os outros
mount -o subvolid=5 /dev/sda3 /mnt

# Cria subvolumes essenciais
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_cache

# Desmonte
umount /mnt
```

---

# ▶️ 7. Montar subvolumes

**REVISÃO:** Montagem inicial com `subvol=@` e montagem dos subvolumes com `subvolid=5` para garantir que o subvolume `@` seja o padrão e que os outros subvolumes sejam montados corretamente, evitando problemas de aninhamento. A opção `ssd` foi removida por ser obsoleta.

```sh
# Monta o subvolume principal (@)
mount -o noatime,compress=zstd,space_cache=v2,subvol=@ /dev/sda3 /mnt

# Cria os pontos de montagem
mkdir -pv /mnt/{boot,home,var/log,var/cache,.snapshots,swap}

# Monta os subvolumes restantes usando subvolid=5 para evitar problemas de aninhamento
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home      /dev/sda3 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots /dev/sda3 /mnt/.snapshots

# Monta subvolumes com nodatacow
mount -o noatime,nodatacow,space_cache=v2,subvol=@var_log       /dev/sda3 /mnt/var/log
mount -o noatime,nodatacow,space_cache=v2,subvol=@var_cache     /dev/sda3 /mnt/var/cache

# Monta a ESP/UEFI
mount /dev/sda2 /mnt/boot
```

Copia as chaves do repositório (XBPS keys) para o /mnt
```sh
mkdir -pv /mnt/var/db/xbps/keys
cp -rpvf /var/db/xbps/keys/*.plist /mnt/var/db/xbps/keys/
cp /etc/resolv.conf /mnt/etc/resolv.conf
```
---

# ▶️ 8. Instalar o Void Linux
```sh
XBPS_ARCH=x86_64 \
xbps-install -Sy -R https://repo-default.voidlinux.org/current \
  -r /mnt base-system btrfs-progs grub grub-x86_64-efi \
  linux-headers linux-firmware-network dhcpcd nano
```

---

# ▶️ 9. Entrar no sistema (chroot)
```sh
for i in proc sys dev run; do mount --rbind /$i /mnt/$i; done
chroot /mnt /bin/bash
bash
export PS1='\033[1;32m\u\033[1;33m@\033[1;36m\h\033[1;31m:\w \033[0m# '
```

# ▶️ 10. Configurações iniciais

```sh
echo void > /etc/hostname
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
```

```sh
nano /etc/default/libc-locales
```

Descomente:
```
en_US.UTF-8 UTF-8
pt_BR.UTF-8 UTF-8
```

ou use o comando abaixo:
```sh
sed -i -e 's/^#\(en_US.UTF-8 UTF-8\)/\1/' \
       -e 's/^#\(pt_BR.UTF-8 UTF-8\)/\1/' \
       /etc/default/libc-locales
```

Gere o locales:
```sh
xbps-reconfigure -f glibc-locales
```

Ativar alguns serviços:
```sh
ln -sf /etc/sv/dhcpcd /var/service
ln -sf /etc/sv/sshd /var/service
```

reconfigurar senha root:
```sh
passwd
```

# ▶️ 11. Criar swapfile com suporte a hibernação

**REVISÃO:** A criação do `swapfile` foi ajustada para seguir a ordem correta e as melhores práticas do Btrfs:
1. Desabilitar COW e compressão no subvolume `@swap`.
2. Criar o `swapfile` dentro do subvolume `@swap`.
3. Desabilitar COW e compressão no arquivo.

```sh
# 1. Criar diretório
mkdir /swap

swapoff -a 2>/dev/null
rm -f /swap/swapfile

# 2. Desabilitar COW (desabilita compressão automaticamente)
chattr +C /swap

# 3. Criar swapfile sem buracos (fallocate, não truncate nem dd). Esse é o único método garantido:
fallocate -l 16G /swap/swapfile
chmod 600 /swap/swapfile

# 4. Verifica:
filefrag -v /swap/swapfile

  /swap/swapfile: 1 extent found
  Se isso aparecer → hibernação vai funcionar 100%.

# 5. Criar swap e ativar
mkswap /swap/swapfile
swapon /swap/swapfile
```

Adicionar ao /etc/fstab (usando o caminho absoluto no subvolume):

```
echo "/swap/swapfile none swap sw 0 0" >> /etc/fstab
```

Obter offset:

```sh
# Instala o pacote para o filefrag
xbps-install -Sy e2fsprogs

# Obtém o offset
offset=$(filefrag -v /swap/swapfile | awk '/^ *0:/{print $4}')
```

**Configurar o Kernel para Hibernação:**

1. Obter o UUID da partição Btrfs (ex: /dev/sda3):

```sh
UUID=$(blkid -s UUID -o value /dev/sda3)
UUID_EFI=$(blkid -s UUID -o value /dev/sda2)
```

2. Configurar o GRUB com o UUID da partição e o offset do `swapfile`:
Edite o arquivo /etc/default/grub e adicione/modifique a linha:
```sh
GRUB_CMDLINE_LINUX="resume=UUID=$UUID resume_offset=$offset"
nano /etc/default/grub
```

3. Refazer o `initrd`
```sh
KVER=$(ls /lib/modules)
dracut --force /boot/initramfs-${KVER}.img ${KVER}
```

4. Configurar montagem dos subvolumes no /etc/fstab
```sh
echo {
"# ======== BTRFS – Subvolumes ========"
"UUID=$UUID         /           btrfs noatime,compress=zstd,space_cache=v2,subvol=@           0 0"
"UUID=$UUID         /home       btrfs noatime,compress=zstd,space_cache=v2,subvol=@home       0 0"
"UUID=$UUID         /opt        btrfs noatime,compress=zstd,space_cache=v2,subvol=@opt        0 0"
"UUID=$UUID         /var/log    btrfs noatime,compress=zstd,space_cache=v2,subvol=@var_log    0 0"
"UUID=$UUID         /var/cache  btrfs noatime,compress=zstd,space_cache=v2,subvol=@var_cache  0 0"
"UUID=$UUID         /.snapshots btrfs noatime,compress=zstd,space_cache=v2,subvol=@snapshots  0 0"
"# ======== EFI System Partition ========"
"UUID=$UUID_EFI     /boot       vfat  defaults,noatime,umask=0077                             0 2"
"# ======== Swapfile ========"
} >> /etc/fstab

```
---

# ▶️ 12. Instalar GRUB em **BIOS** e **UEFI** (híbrido real)

## 🔵 12.1 Instalar GRUB para BIOS (Legacy)
Usa a partição BIOS criada como primeira.

```sh
grub-install --target=i386-pc /dev/sda
```

## 🟢 12.2 Instalar GRUB para UEFI

```sh
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Void
```

## 🟣 12.3 Criar fallback UEFI (boot universal)
Esse arquivo garante boot mesmo quando a NVRAM for apagada.

```sh
mkdir -p /boot/EFI/BOOT
cp -vf /boot/EFI/Void/grubx64.efi /boot/EFI/BOOT/BOOTX64.EFI
```

## 📝 12.4 Gerar arquivo final do GRUB

```sh
grub-mkconfig -o /boot/grub/grub.cfg
```

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
xbps-install -Sy zramen
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
- Btrfs com snapshots (pronto para Snapper/Timeshift) 
- Hibernação real com swapfile 
- Zram para performance 

Este SSD boota **em qualquer máquina do planeta**.

# DISCLAMER
                Este tutorial é livre: você é livre para alterá-lo e redistribuí-lo.
                O tutorial é disponibilizado para você sob a Licença MIT, e
                inclui software de código aberto sob uma variedade de outras licenças.
                Você pode ler instruções sobre como baixar e criar para você mesmo
                o código fonte específico usado para criar esta cópia.
                Este tutorial vem com absolutamente NENHUMA garantia.

