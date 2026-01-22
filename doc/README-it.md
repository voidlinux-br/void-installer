# void-install - programma di installazione brasiliano VOID Linux
## Scaricamento:
- 0 - utilizzando la distribuzione VOID
```bash
echo 'repository=https://void.chililinux.com/voidlinux/current' | sudo tee -a /usr/share/xbps.d/00-repository-main.conf
sudo xbps-install -Syf void-install
sudo void-install
```

- 1 - usando git
- git clone -- Depth=1 https://github.com/voidlinuxbr/void-install

- 2 - utilizzando curl/wget stdin
- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- curl -s -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | bash
- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | bash

- 3 - utilizzando curl/wget
- curl -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- wget https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- chmod +x install.sh
- bash install.sh

## Installazione (dopo il download):
- 1 - utilizzando make
- sudo make install

- 2 - in esecuzione nel repository locale
- ./void-install

Esempi
--------

Esegui `void-install` senza argomenti per ottenere aiuto.

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**Nota:** per eseguire effettivamente il programma di installazione sono necessari privilegi `sudo` o privilegi escalation.

Esegui "void-install -i" per avviare il programma di installazione e scegliere la lingua.

<img alt="void-install-scegli-lingua" src="assets/void-install-scegli-lingua.jpg" larghezza="600" />
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
