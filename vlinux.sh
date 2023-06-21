#!/bin/bash

source minimal.cfg

if [[ $_CONFIG != 1 ]]; then
    echo -e "\E[1m\E[31m=> \E[00mminimal.cfg is not valid!"
    exit 1
fi

mkfs.ext2 "${_BOOT}"
mkfs.ext4 "${_ROOT}"

mkdir -p /mnt/voidlinux/
mount -t ext4 "${_ROOT}" /mnt/voidlinux

mkdir -p /mnt/voidlinux/boot/
mkdir -p /mnt/voidlinux/proc /mnt/voidlinux/sys /mnt/voidlinux/dev

mount -t ext2 "${_BOOT}" /mnt/voidlinux/boot
mount -t proc /proc /mnt/voidlinux/proc
mount -t sysfs /sys /mnt/voidlinux/sys
mount -o bind /dev /mnt/voidlinux/dev

mkdir -p /mnt/voidlinux/boot/extlinux

xbps-install -Sy tar xz
tar xpf /tmp/rootfs.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/voidlinux

mkdir -p /mnt/voidlinux/var/db/xbps/keys /mnt/voidlinux/usr/share
cp -L /etc/resolv.conf /mnt/voidlinux/etc/
cp -a /usr/share/xbps.d /mnt/voidlinux/usr/share/
cp /var/db/xbps/keys/*.plist /mnt/voidlinux/var/db/xbps/keys

xbps-install -r /mnt/voidlinux -SyU base-minimal
xbps-reconfigure -r /mnt/voidlinux -f base-files
chroot /mnt/voidlinux xbps-reconfigure -a

xbps-install -r /mnt/voidlinux -Sy xbps
xbps-install -r /mnt/voidlinux -Sy void-repo-nonfree
chroot /mnt/voidlinux xbps-install -Sy

xbps-install -r /mnt/voidlinux -Sy linux4.19 kernel-libc-headers \
    kmod e2fsprogs dosfstools sudo \
    iproute2 iputils dhclient iw \
    ncurses kbd mdocml man-pages vim ${_PKGS}

echo "${_HOSTNAME}" > /mnt/voidlinux/etc/hostname

cat << EOF > /mnt/voidlinux/etc/rc.local
HOSTNAME="${_HOSTNAME}"
HARDWARECLOCK="${_CLOCK}"
TIMEZONE="${_TIMEZONE}"
KEYMAP="${_KEYMAP}"
EOF

cat << EOF > /mnt/voidlinux/etc/locale.conf
LANG=en_US.UTF-8
LC_COLLATE=C
LC_ALL=en_US.UTF-8
EOF

sed -e "/en_US.UTF-8 UTF-8/s/^\#//" -i /mnt/voidlinux/etc/default/libc-locales
chroot /mnt/voidlinux ln -s /usr/share/zoneinfo/"${_TIMEZONE}" /etc/localtime

echo -e "${_PASS}\n${_PASS}" | chroot /mnt/voidlinux passwd root
chroot /mnt/voidlinux useradd -N -p "$(openssl passwd -1 "{$_PASS}")" "${_USER}"
chroot /mnt/voidlinux usermod -G wheel,audio,users "${_USER}"

KVER=$(chroot /mnt/voidlinux xbps-query -RS linux4.19 -ppkgver | sed 's/linux4.19-//')
chroot /mnt/voidlinux xbps-reconfigure -f linux4.19

cat << EOF > /mnt/voidlinux/etc/fstab
UUID=$(blkid -o value -s UUID "${_BOOT}") /boot ext2 defaults 0 2
UUID=$(blkid -o value -s UUID "${_ROOT}") / ext4 defaults 0 1
EOF

cat << EOF > /mnt/voidlinux/boot/extlinux/extlinux.conf
DEFAULT rootfs

LABEL rootfs
    LINUX /boot/vmlinuz-${KVER}
    INITRD /boot/initramfs-${KVER}.img
    APPEND root=${_ROOT} rw
EOF

chroot /mnt/voidlinux xbps-install -Sy syslinux mkinitcpio mkinitcpio-udev
chroot /mnt/voidlinux mkinitcpio -g /boot/initramfs-"${KVER}".img -k "${KVER}"
chroot /mnt/voidlinux dd bs=440 conv=notrunc count=1 if=/usr/lib/syslinux/mbr.bin of=/dev/sda
chroot /mnt/voidlinux extlinux --install /boot/extlinux
chroot /mnt/voidlinux ln -snf . /boot/boot
chroot /mnt/voidlinux cp /usr/lib/syslinux/{libcom32.c32,libutil.c32} /boot/extlinux
xbps-reconfigure -r /mnt/voidlinux -f glibc-locales syslinux mkinitcpio

chroot /mnt/voidlinux ln -snf /usr/lib /lib64
chroot /mnt/voidlinux ln -snf /usr/lib32 /lib32

chroot /mnt/voidlinux ln -s /etc/sv/agetty-tty1 /etc/sv/agetty-tty2 \
/etc/sv/dhclient /etc/sv/udevd /etc/sv/uuidd /etc/sv/dmeventd \
/etc/runit/runsvdir/current/
