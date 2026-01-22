# void-install - VOID Linux 브라질 설치 프로그램
## 다운로드:
- 0 - distro VOID 사용
```bash
echo 'repository=https://void.chililinux.com/voidlinux/current' | sudo tee -a /usr/share/xbps.d/00-repository-main.conf
sudo xbps-install -Syf 무효 설치
sudo 무효 설치
```

- 1 - 자식 사용
- git clone --깊이=1 https://github.com/voidlinuxbr/void-install

- 2 - 컬/wget stdin 사용
- bash <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- bash <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh)
- 컬 -s -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | 세게 때리다
- wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh | 세게 때리다

- 3 - 컬/wget 사용
- 컬 -O https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- wget https://raw.githubusercontent.com/voidlinuxbr/void-install/master/install.sh
- chmod +x install.sh
- 배시 설치.sh

## 설치(다운로드 후):
- 1 - make 사용
- sudo make 설치

- 2 - 로컬 저장소에서 실행 중
- ./void-install

예
--------

도움을 받으려면 인수 없이 `void-install`을 실행하세요.

<img alt="void-install-help" src="assets/void-install-help.jpg" width="600" />

**참고:** 실제로 설치 프로그램을 실행하려면 `sudo` 또는 에스컬레이션된 권한이 필요합니다.

`void-install -i`를 실행하여 설치 프로그램을 시작하고 언어를 선택하세요.

<img alt="void-install-choose-언어" src="assets/void-install-choose-언어.jpg" width="600" />
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
