# 🔥 Instalação do Void Linux com Btrfs + Subvolumes + Swapfile + UEFI (Guia Completo)

## (Somente UEFI, sem BIOS/Legacy)

Este guia instala o Void Linux com:

- Partição LUKS2 para o sistema
- Btrfs com subvolumes
- Swapfile seguro dentro do Btrfs
- Boot somente UEFI (sem suporte a BIOS/Legacy)

---

## ▶️ 1. Iniciar a Instalação

Inicie pelo ISO do Void Linux (x86_64 glibc ou musl).  
Abra um terminal como root.

### Trocar layout de teclado para ABNT2

[code]
loadkeys br-abnt2
[/code]

---

## ▶️ 2. Identificar o disco

[code]
lsblk
[/code]

Identifique o disco onde o Void será instalado (ex.: /dev/sda).

---

## ▶️ 3. Particionar com cfdisk (GPT)

[code]
cfdisk -z /dev/sda
[/code]

- Selecione **GPT**.

Crie as partições:

1. **ESP** — EFI System Partition — 512MB — tipo: *EFI System*
2. **Sistema (LUKS → Btrfs)** — resto do disco — tipo: *Linux filesystem*

Salve e saia.

---

## ▶️ 4. Criptografar e formatar

### Criptografar a partição de sistema (Btrfs dentro de LUKS)

Confirme com `YES`:

[code]
cryptsetup luksFormat /dev/sda2
[/code]

### Abrir a partição criptografada

Vamos mapear como `cryptroot`:

[code]
cryptsetup open /dev/sda2 cryptroot
[/code]

### Formatar o volume Btrfs

[code]
mkfs.btrfs /dev/mapper/cryptroot
[/code]

### Formatar a ESP como FAT32

[code]
mkfs.fat -F32 /dev/sda1
[/code]

---

## ▶️ 5. Criar subvolumes Btrfs

Monte o dispositivo Btrfs para criar os subvolumes:

[code]
mount /dev/mapper/cryptroot /mnt
[/code]

Crie os subvolumes principais:

[code]
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@snapshots
[/code]

> Observação:
> - Não criamos mais **@swap** nem **@boot**.
> - O swapfile ficará em `/swapfile` no subvolume `@`.
> - `/boot` será apenas um diretório dentro do `@`, e a ESP será montada em `/boot/efi`.

Desmonte:

[code]
umount /mnt
[/code]

---

## ▶️ 6. Montar os subvolumes

### Montar o subvolume raiz (@)

[code]
mount -o subvol=@,compress=zstd:3 /dev/mapper/cryptroot /mnt
[/code]

### Criar pontos de montagem

[code]
mkdir -p /mnt/{home,var/log,var/cache,.snapshots}
mkdir -p /mnt/boot
mkdir -p /mnt/boot/efi
[/code]

> Note que agora `/boot` é só diretório normal dentro do `@`, e não há mais subvolume `@boot`.

### Montar os subvolumes restantes

[code]
mount -o subvol=@home,compress=zstd:3 /dev/mapper/cryptroot /mnt/home
mount -o subvol=@log /dev/mapper/cryptroot /mnt/var/log
mount -o subvol=@cache /dev/mapper/cryptroot /mnt/var/cache
mount -o subvol=@snapshots,compress=zstd:3 /dev/mapper/cryptroot /mnt/.snapshots
[/code]

### Montar a ESP em /boot/efi

[code]
mount /dev/sda1 /mnt/boot/efi
[/code]

> Não há mais montagem de `/mnt/boot` como subvolume separado.
> Tudo que ficar em `/boot` estará dentro do Btrfs em `@`, e a ESP estará em `/boot/efi`.

---

## ▶️ 7. Instalar o sistema base

[code]
xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt base-system btrfs-progs cryptsetup grub-x86_64-efi dracut linux linux-firmware linux-firmware-network glibc-locales xtools vim
[/code]

Isso garante:

- `btrfs-progs` → suporte ao Btrfs e subvolumes
- `cryptsetup` → LUKS
- `dracut` → initramfs com suporte a LUKS
- `grub-x86_64-efi` → bootloader UEFI
- `linux` → kernel
- `linux-firmware-network` → drivers de rede
- `glibc-locales` → locales
- `xtools` → necessário para usar `xgenfstab`
- `vim` → editor básico

---

## ▶️ 8. Gerar fstab

[code]
xgenfstab -U /mnt > /mnt/etc/fstab
[/code]

Depois, confira o conteúdo de `/mnt/etc/fstab` para garantir que os subvolumes foram detectados corretamente.

---

## ▶️ 9. Preparar chroot

Monte bind dos pseudo-sistemas:

[code]
for i in /dev /proc /sys /run; do mount --rbind $i /mnt$i; done
[/code]

Entrar no chroot:

[code]
chroot /mnt /bin/bash
[/code]

---

## ▶️ 10. Configurar o GRUB (LUKS + Btrfs)

Primeiro, pegue a UUID da partição LUKS (`/dev/sda2`):

[code]
blkid /dev/sda2
[/code]

Você verá algo como:

[code]
/dev/sda2: UUID="31c87e1e-dd47-4ed7-bd0c-780aa52cd1ea" TYPE="crypto_LUKS"
[/code]

Anote o UUID (sem aspas).

Edite o `/etc/default/grub`:

[code]
vim /etc/default/grub
[/code]

Adicione/edite as linhas:

[code]
GRUB_ENABLE_CRYPTODISK=y
[/code]

[code]
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.luks.uuid=31c87e1e-dd47-4ed7-bd0c-780aa52cd1ea rd.luks.name=31c87e1e-dd47-4ed7-bd0c-780aa52cd1ea=cryptroot root=/dev/mapper/cryptroot"
[/code]

> Substitua o UUID pelo seu real.
> Aqui estamos dizendo pro initramfs:
> - qual LUKS abrir
> - qual nome dar pro mapeamento (`cryptroot`)
> - onde está a raiz (`root=/dev/mapper/cryptroot`)

Crie o path para o grub (caso ainda não exista):

[code]
mkdir -p /boot/grub
[/code]

Gerar o `grub.cfg`:

[code]
grub-mkconfig -o /boot/grub/grub.cfg
[/code]

---

## ▶️ 11. Instalar o GRUB em modo UEFI

Instalar o GRUB apontando para a ESP em `/boot/efi`:

[code]
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="VoidLinux" --recheck
[/code]

---

## ▶️ 12. Gerar o INITRAMFS com Dracut

Descobrir a versão do kernel instalada:

[code]
ls /lib/modules
[/code]

Você verá algo como:

[code]
6.12.58_1
[/code]

Gere o initramfs:

[code]
dracut --kver 6.12.58_1 --force
[/code]

> Ajuste a versão (`6.12.58_1`) conforme a sua saída do `ls /lib/modules`.

---

## ▶️ 13. Configurações básicas de sistema

### Resolver DNS provisório

[code]
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
[/code]

### Hostname

[code]
echo void > /etc/hostname
[/code]

### Timezone

[code]
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
[/code]

### Locales

Edite as linhas necessárias em `/etc/default/libc-locales`:

[code]
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/default/libc-locales
sed -i 's/#pt_BR.UTF-8/pt_BR.UTF-8/' /etc/default/libc-locales
[/code]

Gerar os locales:

[code]
xbps-reconfigure -f glibc-locales
[/code]

---

## ▶️ 14. Senha de root

[code]
passwd
[/code]

Defina a senha do usuário root.

---

## ▶️ 15. Criar swapfile em Btrfs (modo correto)

Agora, com o Btrfs montado em `/`, crie o swapfile na raiz (sem subvolume separado):

[code]
btrfs filesystem mkswapfile --size 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
[/code]

Adicione a entrada do swapfile no `/etc/fstab`:

[code]
echo "/swapfile none swap sw 0 0" >> /etc/fstab
[/code]

> Observações importantes:
> - O comando `btrfs filesystem mkswapfile` cuida de desativar COW e garantir contiguidade.
> - Não usamos mais `/swap/swapfile`, nem subvolume `@swap`.
> - Simples e totalmente compatível com hibernação futura (desde que configurada corretamente).

---

## ▶️ 16. Finalizar, sair do chroot e reboot

Sair do chroot:

[code]
exit
[/code]

Desmontar tudo recursivamente:

[code]
umount -R /mnt
[/code]

Desativar swap (se ainda estiver ativa):

[code]
swapoff -a
[/code]

Fechar o LUKS:

[code]
cryptsetup close cryptroot
[/code]

Reiniciar:

[code]
reboot
[/code]

---

## 🎉 Conclusão

Após o reboot:

- O firmware UEFI deve detectar a entrada **VoidLinux** criada pelo GRUB.
- Ao dar boot:
  - O GRUB vai pedir a passphrase do LUKS.
  - O initramfs abrirá `/dev/sda2` como `cryptroot`.
  - O Btrfs será montado com o subvolume `@` como `/`.
  - Os subvolumes serão montados conforme seu `/etc/fstab`.
  - O swapfile em `/swapfile` estará ativo normalmente.

Você agora tem:

- 🔐 LUKS2  
- 🗂️ Btrfs com subvolumes bem organizados  
- 📁 Swapfile seguro no próprio Btrfs (sem gambi de subvolume)  
- ⚙️ Boot UEFI limpo com GRUB

