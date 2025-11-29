# 🐧 Void Linux + XFCE4 — Tutorial Definitivo

## 1. Atualizar o sistema
```
sudo xbps-install -Syu
```

## 2. Instalar Xorg + Xinit + Xterm
```
sudo xbps-install -y xorg xinit xterm
```

## 3. Instalar XFCE4 completo
```
sudo xbps-install -y xfce4
```

## 4. Instalar LXDM (display manager leve)
```
sudo xbps-install -y lxdm
```

## 5. Instalar áudio com PipeWire (som completo)

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


## 6. Drivers de vídeo (escolher apenas um)

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

### Nvidia proprietária
```
sudo xbps-install -y mesa-nouveau-dri
```

## 7. Desativar o XFCE-Polkit (bugado — não usar)
```
mkdir -p ~/.config/autostart
cp /etc/xdg/autostart/xfce-polkit.desktop ~/.config/autostart/
sed -i 's/^Hidden=.*/Hidden=true/' ~/.config/autostart/xfce-polkit.desktop || echo 'Hidden=true' >> ~/.config/autostart/xfce-polkit.desktop
```

## 8. Criar .xinitrc (opcional para startx)
```
cat <<EOF > ~/.xinitrc
#!/bin/sh
setxkbmap -layout br -variant abnt2 &
xsetroot -cursor_name left_ptr &
exec startxfce4
EOF
```

## 9. Ativar serviços obrigatórios (runit)
```
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
sudo ln -s /etc/sv/polkitd /var/service/
sudo ln -s /etc/sv/NetworkManager /var/service/
sudo ln -s /etc/sv/lxdm /var/service/
```

## Finalização
- Se LXDM estiver ativo: boot direto em GUI.
- Se quiser modo clássico: startx
