#!/bin/sh
# POSIX sh compatible installer
#
#  install.sh
#  Created: 2023/01/10
#  Altered: 2024/09/23
#  Updated: ter 06 jan 2026 22:00:53 -04
#
#  Copyright (c) 2019-2026, Vilmar Catafesta <vcatafesta@gmail.com>
#  Copyright (c) 2025-2026, VoidLinuxBR Team
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#sh <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh)
#sh <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh)
#source <(curl -s -L https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh)
#source <(wget -q -O - https://raw.githubusercontent.com/voidlinuxbr/void-installer/master/install.sh)

#!/bin/sh
# install.sh — POSIX sh, colorido, compatível com ISO (sh)

###############################################################################
# CORES ANSI (POSIX)
###############################################################################
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'
BOLD='\033[1m'

# desliga cores se não for TTY
[ -t 1 ] || {
   RED= GREEN= YELLOW= BLUE= CYAN= RESET= BOLD=
}

###############################################################################
# FUNÇÕES DE LOG
###############################################################################
msg()   { printf "%b\n" "${CYAN}==>${RESET} $*"; }
ok()    { printf "%b\n" "${GREEN}[OK]${RESET} $*"; }
warn()  { printf "%b\n" "${YELLOW}[WARN]${RESET} $*"; }
err()   { printf "%b\n" "${RED}[ERRO]${RESET} $*" >&2; }
oops()  { err "$*"; exit 1; }

###############################################################################
# CONFIGURAÇÃO
###############################################################################
umask 0022

url="https://raw.githubusercontent.com/voidlinuxbr/void-installer/master"
url_blob="https://github.com/voidlinuxbr/void-installer/blob/master"

files_bin="void-install void-testmirror void-remove-vg void-clonedisk"
files_home="LICENSE README.md"
files_lang="void-install void-testmirror void-remove-vg void-clonedisk"
files_blob="void-x86_64-base-custom-current.tar.xz"
idioma="en es it de fr ru zh-CN zh-TW ja ko"

tmpDir="$HOME/void-installer"
dir_locale="usr/share/locale"

###############################################################################
# PREPARAÇÃO
###############################################################################
msg "Preparando diretório temporário"
[ -d "$tmpDir" ] || mkdir -p "$tmpDir" || oops "Unable to create $tmpDir"
ok "Diretório $tmpDir pronto"

require_util() {
   command -v "$1" >/dev/null 2>&1 ||
      oops "Você não tem '$1' instalado (necessário para $2)"
}

###############################################################################
# DOWNLOAD TOOL
###############################################################################
if command -v curl >/dev/null 2>&1; then
   cmdfetch() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
   cmdfetch() { wget -q "$1" -O "$2"; }
else
   require_util curl downloader
   require_util wget downloader
fi

###############################################################################
# DOWNLOAD BINÁRIOS
###############################################################################
for f in $files_bin; do
   msg "Baixando $f"
   cmdfetch "$url/$f" "$tmpDir/$f" || oops "Falha no download: $f"
   ok "$f baixado"
done

###############################################################################
# DOWNLOAD ARQUIVOS HOME
###############################################################################
for f in $files_home; do
   msg "Baixando $f"
   cmdfetch "$url/$f" "$tmpDir/$f" || oops "Falha no download: $f"
   ok "$f baixado"
done

###############################################################################
# DOWNLOAD BLOBS
###############################################################################
for f in $files_blob; do
   msg "Baixando $f"
   cmdfetch "$url_blob/$f" "$tmpDir/$f" || oops "Falha no download: $f"
   ok "$f baixado"
done

###############################################################################
# DOWNLOAD IDIOMAS
###############################################################################
for lang in $idioma; do
   for f in $files_lang; do
      target="$tmpDir/$dir_locale/$lang/LC_MESSAGES"
      [ -d "$target" ] || mkdir -p "$target" || oops "Unable to create $target"
      msg "Idioma $lang: $f.mo"
      cmdfetch "$url/$dir_locale/$lang/LC_MESSAGES/$f.mo" \
         "$target/$f.mo" >/dev/null 2>&1 || true
   done
done
ok "Idiomas processados"

###############################################################################
# INSTALA LOCALES
###############################################################################
msg "Instalando arquivos de idioma"
sudo cp -rf "$tmpDir/usr/share/locale/"* /usr/share/locale/ \
   || oops "Falha ao instalar locales"
ok "Locales instalados"

###############################################################################
# INSTALA BINÁRIOS
###############################################################################
msg "Instalando binários"
for f in $files_bin; do
   sudo chmod +x "$tmpDir/$f"
   sudo cp -f "$tmpDir/$f" /usr/bin/ || oops "Falha ao instalar $f"
done
ok "Binários instalados"

###############################################################################
# FINAL
###############################################################################
echo
msg "Conteúdo de $tmpDir"
ls -la --color=auto "$tmpDir"

echo
printf "%b\n" "${BOLD}${GREEN}Pronto! Para continuar:${RESET}"
echo
printf "%b\n" "   ${YELLOW}sudo bash void-install${RESET}"
echo
printf "%b\n" "${CYAN}ou entre em:${RESET} ${BOLD}$tmpDir${RESET}"
printf "%b\n" "   ${BLUE}cd $tmpDir${RESET}"
printf "%b\n" "   ${YELLOW}sudo bash void-install${RESET}"
echo
