# 🐧 Void Linux + GNOME — Tutorial Definitivo

## 1. Atualizar o sistema
```
sudo xbps-install -Syu
```

## 2. Instalar o GNOME completo (meta-pacote)
```
sudo xbps-install -y gnome
```

## 3. Instalar o GDM (display manager oficial)
```
sudo xbps-install -y gdm
```

## 4. Instalar áudio com PipeWire (som completo)

### PipeWire + WirePlumber + ALSA + Pulse compat
```

sudo xbps-install -y \
  pipewire \
  wireplumber \
  alsa-pipewire \
  libjack-pipewire \
  alsa-utils \
  pavucontrol
```

## 5. Drivers de vídeo (escolher apenas um)

### Intel
```
sudo xbps-install -y mesa-dri linux-firmware-intel
```

### AMD nova (amdgpu)
```
sudo xbps-install -y mesa-dri xf86-video-amdgpu
```

### AMD antiga
```
sudo xbps-install -y mesa-dri xf86-video-ati
```

### Nvidia (driver aberto)
```
sudo xbps-install -y mesa-nouveau-dri
```

## 6. Ativar serviços obrigatórios (runit)
```
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
sudo ln -s /etc/sv/polkitd /var/service/
sudo ln -s /etc/sv/NetworkManager /var/service/
sudo ln -s /etc/sv/gdm /var/service/
```

## 7. (Opcional) Criar .xinitrc para startx
```
cat <<EOF > ~/.xinitrc
#!/bin/sh
setxkbmap -layout br -variant abnt2 &
exec gnome-session
EOF
```

## Finalização
- Usando GDM → o sistema inicia direto no GNOME.
- Sem GDM → usar `startx` (se `.xinitrc` existir).
