# void-install – VOID Linux brasilianisches Installationsprogramm
## Herunterladen:
- 0 - mit Distribution VOID
```bash
echo 'repository=https://void.chililinux.com/voidlinux/current' | sudo tee -a /usr/share/xbps.d/00-repository-main.conf
sudo xbps-install -Syf void-install
sudo void-install
```

- 1 - mit Git
- git clone --length=1 https://github.com/voidlinuxbr/void-install

- 2 - mit Curl/Wget stdin
- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- curl -s -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | bash
- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | bash

- 3 - mit Curl/Wget
- curl -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- wget https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- chmod +x install.sh
- bash install.sh

## Installation (nach dem Download):
- 1 - mit make
- sudo make install

- 2 - Läuft im lokalen Repo
- ./void-install

Beispiele
--------

Führen Sie „void-install“ ohne Argumente aus, um Hilfe zu erhalten.

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**Hinweis:** Für die tatsächliche Ausführung des Installationsprogramms sind „sudo“ oder erweiterte Berechtigungen erforderlich.

Führen Sie „void-install -i“ aus, um das Installationsprogramm zu starten und die Sprache auszuwählen.

<img alt="void-install-choose-Language" src="assets/void-install-choose-Language.jpg" width="600" />
<img alt="void-install-main-menu" src="assets/void-install-main-menu.jpg" width="600" />
<img alt="void-install-choose-mirror" src="assets/void-install-choose-mirror.jpg" width="600" />
<img alt="void-install-choose-source" src="assets/void-install-choose-source.jpg" width="600" />
<img alt="void-install-choose-disk" src="assets/void-install-choose-disk.jpg" width="600" />
<img alt="void-install-choose-filesystem" src="assets/void-install-choose-filesystem.jpg" width="600" />
<img alt="void-install-choose-timezone" src="assets/void-install-choose-timezone.jpg" width="600" />
<img alt="void-install-choose-wm" src="assets/void-install-choose-wm.jpg" width="600" />
<img alt="void-install-choose-extra" src="assets/void-install-choose-extra.jpg" width="600" />
<img alt="void-install-choose-fde" src="assets/void-install-choose-fde.jpg" width="600" />
<img alt="void-install-clear-vg" src="assets/void-install-clear-vg.jpg" width="600" />
<img alt="void-install-choose-wifi" src="assets/void-install-choose-wifi.jpg" width="600" />
