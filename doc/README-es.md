# void-install - VOID Linux Brazilian installer
## Descargar:
- 0 - usando distribución VOID
```bash
echo 'repositorio=https://void.chililinux.com/voidlinux/current' | sudo tee -a /usr/share/xbps.d/00-repository-main.conf
sudo xbps-install -Syf void-install
sudo void-instalar
```

- 1 - usando git
- git clone --depth=1 https://github.com/voidlinuxbr/void-install

- 2 - usando curl/wget stdin
- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- curl -s -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | intento
- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | intento

- 3 - usando curl/wget
- curl -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- wget https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- chmod +x instalar.sh
- bash install.sh

## Instalación (después de la descarga):
- 1 - usando hacer
-sudo hacer instalar

- 2 - ejecutándose en el repositorio local
- ./void-install

Ejemplos
--------

Ejecute `void-install` sin ningún argumento para obtener ayuda.

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**Nota:** Se requieren `sudo` o privilegios escalados para ejecutar el instalador.

Ejecute `void-install -i` para iniciar el instalador y elegir el idioma.

<img alt="void-install-choose-language" src="assets/void-install-choose-language.jpg" width="600" />
<img alt="void-install-main-menu" src="assets/void-install-main-menu.jpg" width="600" />
<img alt="void-install-choose-mirror" src="assets/void-install-choose-mirror.jpg" width="600" />
<img alt="void-install-choose-source" src="assets/void-install-choose-source.jpg" width="600" />
<img alt="void-install-choose-disk" src="assets/void-install-choose-disk.jpg" width="600" />
<img alt="void-install-choose-filesystem" src="assets/void-install-choose-filesystem.jpg" ancho="600" />
<img alt="void-install-choose-timezone" src="assets/void-install-choose-timezone.jpg" width="600" />
<img alt="void-install-choose-wm" src="assets/void-install-choose-wm.jpg" width="600" />
<img alt="void-install-choose-extra" src="assets/void-install-choose-extra.jpg" width="600" />
<img alt="void-install-choose-fde" src="assets/void-install-choose-fde.jpg" width="600" />
<img alt="void-install-clear-vg" src="assets/void-install-clear-vg.jpg" ancho="600" />
<img alt="void-install-choose-wifi" src="assets/void-install-choose-wifi.jpg" width="600" />
