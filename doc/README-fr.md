# void-install - Programme d'installation brésilien de VOID Linux
## Télécharger:
- 0 - en utilisant la distribution VOID
```bash
echo 'repository=https://void.chililinux.com/voidlinux/current' | sudo tee -a /usr/share/xbps.d/00-repository-main.conf
sudo xbps-install -Syf void-install
sudo void-install
```

- 1 - utiliser git
- git clone --degree=1 https://github.com/voidlinuxbr/void-install

- 2 - en utilisant curl/wget stdin
- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- curl -s -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | frapper
- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | frapper

- 3 - en utilisant curl/wget
- curl -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- wget https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- chmod +x install.sh
- bash install.sh

## Installation (après téléchargement) :
- 1 - en utilisant make
- sudo make install

- 2 - exécuté dans un dépôt local
- ./void-install

Exemples
---------

Exécutez `void-install` sans aucun argument pour obtenir de l'aide.

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**Remarque :** Des privilèges « sudo » ou élevés sont requis pour exécuter réellement le programme d'installation.

Exécutez `void-install -i` pour démarrer le programme d'installation et choisissez la langue.

<img alt="void-install-choose-langue" src="assets/void-install-choose-langue.jpg" width="600" />
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
