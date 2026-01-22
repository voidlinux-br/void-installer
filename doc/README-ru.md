# void-install — бразильский установщик VOID Linux
## Скачать:
- 0 - использование дистрибутива VOID
```bash
echo 'repository=https://void.chililinux.com/voidlinux/current' | sudo tee -a /usr/share/xbps.d/00-repository-main.conf
sudo xbps-install -Syf void-install
sudo void-установить
```

- 1 - использование git
- git clone --length=1 https://github.com/voidlinuxbr/void-install

- 2 - использование стандартного ввода Curl/wget
- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- завиток -s -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | бить
- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | бить

- 3 - использование curl/wget
- завиток -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- wget https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- chmod +x install.sh
- Баш install.sh

## Установка (после скачивания):
- 1 - с помощью make
- sudo сделать установку

- 2 - запуск в локальном репо
- ./void-install

Примеры
--------

Запустите void-install без каких-либо аргументов, чтобы получить помощь.

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**Примечание.** Для фактического запуска установщика необходимы `sudo` или повышенные привилегии.

Запустите `void-install -i`, чтобы запустить установщик, и выберите язык.

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
