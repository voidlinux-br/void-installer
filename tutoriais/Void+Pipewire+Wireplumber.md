
# 🟦 PipeWire + WirePlumber no Void Linux

## 🎯 Objetivo Guia atualizado e oficial para 2025 (sem runit) para gerenciamento de som no Void Linux, sob Pipewire. Este guia segue exatamente o que está na documentação oficial

https://docs.voidlinux.org/config/media/pipewire.html

## É válido tanto para Xorg, Wayland, WMs manuais (i3, bspwm, dwm, sway…), quanto para desktops completos (XFCE, LXQt, KDE, GNOME).

---

## ✔️ 1. Instalar PipeWire.

## O pacote pipewire já contém o WirePlumber, que é o session manager moderno e oficial. Não existe mais “pipewire-pulse”, “pipewire-runit”, “wireplumber-runit”, etc.

```bash
sudo xbps-install -S pipewire
```

## ✔️ 2. Ativar interfaces desejadas: PulseAudio, ALSA e Jack

## O Void usa drop-in configs em:

```bash
~/.config/pipewire/pipewire.conf.d/ (usuário)
```

## ou 

```bash
bash/etc/pipewire/pipewire.conf.d/ (sistema)
```

## Crie a pasta:

```bash
mkdir -p ~/.config/pipewire/pipewire.conf.d
mkdir -p ~/.config/pipewire/pipewire-pulse.conf.d
```

## 🔊 2.1 Habilitar substituição do PulseAudio (pipewire-pulse)

## Crie o link de configuração recomendado:

```bash
ln -s /usr/share/examples/pipewire/pipewire-pulse.conf ~/.config/pipewire/
```

## E o diretório de drop-ins:

```bash
ln -s /usr/share/examples/pipewire/pipewire-pulse.conf.d/* ~/.config/pipewire/pipewire-pulse.conf.d/
```

## Isso garante compatibilidade com qualquer app que use PulseAudio.

## 🎧 2.2 Ativar ALSA (opcional, mas recomendado)

```bash
ln -s /usr/share/examples/pipewire/pipewire.conf.d/10-alsa.conf ~/.config/pipewire/pipewire.conf.d/
```

## 🎸 2.3 Ativar JACK (apenas se você usa apps de áudio profissionais)

```bash
ln -s /usr/share/examples/pipewire/pipewire.conf.d/10-jack.conf ~/.config/pipewire/pipewire.conf.d/
```

## ✔️ 3. Iniciar PipeWire automaticamente (modo oficial)

## PipeWire não usa mais runit. Ele funciona no nível de sessão do usuário, igual o PulseAudio fazia.

## Dependendo do seu ambiente gráfico:

## 🖥️ 3.1 XFCE, LXQt, KDE, GNOME, Cinnamon, Mate

- Esses ambientes iniciam PipeWire automaticamente (via DBus).
- Você não precisa fazer nada.
- Faça login novamente e o som deve funcionar.

## 🪟 3.2 Window managers (i3, bspwm, openbox, dwm) – iniciar manualmente

## Adicione ao seu arquivo de sessão (ex: ~/.xinitrc, ~/.xprofile, ~/.config/sway/config, etc):

```bash
pipewire &
wireplumber &
pipewire-pulse &
```

## Em Wayland com dbus-run-session, use:

```bash
dbus-run-session pipewire &
dbus-run-session wireplumber &
```

## ✔️ 4. Verificar se tudo está funcionando

## PipeWire ativo

```bash
ps aux | grep pipewire
```

## WirePlumber ativo

```bash
ps aux | grep wireplumber
```

## PulseAudio compatível rodando via PipeWire

```bash
PulseAudio compatível rodando via PipeWire
```

## A saída deve mostrar:

```bash
Server Name: PulseAudio (on PipeWire 0.3.x)
```

## ✔️ 5. Grupos necessários (se você NÃO usa elogind)

## Caso esteja usando runit puro sem elogind:

```bash
sudo usermod -aG audio,video $USER
```

## Depois:

```bash
sudo loginctl enable-linger $USER
```

## Ou simplesmente saia e entre novamente no sistema.

## ✔️ 6. Troubleshooting (casos comuns)

## 🔧 Sem som após migrar de PulseAudio antigo. Remova restos de config antiga:

```bash
rm -rf ~/.config/pulse
rm -rf ~/.pulse
```

## Reinicie a sessão.

## 🔧 PipeWire não sobe

## Verifique se seu ambiente fornece DBus:

```bash
ps aux | grep dbus
```

## Caso não esteja rodando:

```bash
dbus-run-session -- pipewire
```

## 🔧 Apps dizendo “não encontra Pulseaudio”

## Verifique se o módulo pipewire-pulse está rodando:

```bash
pactl info
```

## Em caso da erro:

```bash
pipewire-pulse &
```

## ✔️ 7. O jeito oficial e recomendado pelo Void (resumo curto)

## Instalar:

```bash
sudo xbps-install pipewire
```

## Configurar: Criar links em 

```bash
~/.config/pipewire/pipewire.conf.d/
```

## Iniciar: 

- Desktop environments → automático
- Window managers → iniciar no .xinitrc / .xprofile

## Sem runit:

- PipeWire funciona no nível de usuário, não via serviço do sistema.

## Este procedimento está 100% alinhado à documentação oficial do Void Linux.

---

🎯 THAT'S ALL FOLKS!

👉 Contato: zerolies@disroot.org
👉 https://t.me/z3r0l135













