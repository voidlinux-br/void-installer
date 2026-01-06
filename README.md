# void-install - VOID Linux Brazilian installer

## Download:

- 1 - using git
	- git clone --depth=1 https://github.com/voidlinuxbr/void-installer

- 2 - using curl/wget stdin
	- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh)
	- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh)
	- curl -s -O https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh | bash
	- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh | bash

- 3 - using curl/wget
	- curl -O https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh
	- wget https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh
	- chmod +x install.sh
	- bash ./install.sh

## Installation (after download):
- 1 - using make
	- sudo make install

- 2 - running in local repo
	- ./void-install

Examples
--------

Run `void-install` without any arguments to get help.

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**Note:** `sudo` or escalated privileges are required to actually run the installer.

Run `void-install -i` to start the installer and choose language.

<img alt="void-install-choose-language" src="assets/void-install-choose-language.jpg" width="600" />
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
