# void-install - VOID Linux ブラジルインストーラー
## ダウンロード:
- 0 - ディストリビューション VOID を使用
```bash
エコー 'repository=https://void.chililinux.com/voidlinux/current' | sudo tee -a /usr/share/xbps.d/00-repository-main.conf
sudo xbps-install -Syf void-install
sudo void-install
```

- 1 - git を使用する
- git clone -- Depth=1 https://github.com/voidlinuxbr/void-install

- 2 -curl/wget stdin を使用する
- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
-curl -s -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh |バッシュ
- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh |バッシュ

- 3 -curl/wgetを使用する
-curl -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- wget https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- chmod +x install.sh
- bash install.sh

## インストール (ダウンロード後):
- 1 - make を使用する
- sudo make install

- 2 - ローカル リポジトリで実行
- ./void-install

例
--------

ヘルプを表示するには、引数を指定せずに `void-install` を実行します。

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**注意:** インストーラーを実際に実行するには、「sudo」または昇格された権限が必要です。

`void-install -i` を実行してインストーラーを起動し、言語を選択します。

<img alt="void-install-choose- language" src="assets/void-install-choose- language.jpg" width="600" />
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
