# void-install - VOID Linux 巴西安装程序
＃＃ 下载：
- 0 - 使用发行版 VOID
```bash
回声'存储库= https://void.chililinux.com/voidlinux/current' | sudo tee -a /usr/share/xbps.d/00-repository-main.conf
sudo xbps-install -Syf void-install
sudo void 安装
```

- 1 - 使用git
- git克隆--深度= 1 https://github.com/voidlinuxbr/void-install

- 2 - 使用curl/wget stdin
- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
-curl -s -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh |巴什
- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh |巴什

- 3 - 使用curl/wget
-curl -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- wget https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
-chmod +x install.sh
-bash安装.sh

## 安装（下载后）：
- 1 - 使用make
- 须藤进行安装

- 2 - 在本地存储库中运行
- ./void-安装

示例
--------

运行不带任何参数的“void-install”来获取帮助。

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**注意：** 实际运行安装程序需要 `sudo` 或升级权限。

运行“void-install -i”启动安装程序并选择语言。

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
