#!/bin/sh

#sh <(curl -L https://raw.githubusercontent.com/voidlinux-br/void-installer/master/install.sh)
#sh <(wget https://raw.githubusercontent.com/voidlinux-br/void-installer/master/install.sh)

{
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

umask 0022
url="https://raw.githubusercontent.com/voidlinux-br/void-installer/master"
files=('ChangeLog' 'INSTALL' 'LICENSE' 'MAINTAINERS' 'Makefile' 'README' 'README.md' 'void-install')
tmpDir=~/void-installer
[[ ! -d "$tmpDir" ]] && { mkdir "$tmpDir" || oops "Não é possível criar diretório temporário para baixar arquivos";}

require_util() {
	command -v "$1" > /dev/null 2>&1 ||
		oops "você não tem '$1' instalado, que eu preciso para $2"
}

#require_util tar "descompatar o tarball"

if command -v curl > /dev/null 2>&1; then
	cmdfetch() { curl --silent --insecure --fail -L "$1" -o "$2"; }
elif command -v wget > /dev/null 2>&1; then
	cmdfetch() { wget "$1" -O "$2"; }
else
	oops "você não tem wget ou curl instalado, o que eu preciso para baixar os arquivos"
fi

for f in "${files[@]}"
do
	echo "downloading $f from '$url' to '$tmpDir'..."
	cmdfetch "$url/$f" "$tmpDir/$f" || oops "falha no download '$url/$f'"
done

chmod +x $tmpDir/void-install
ls -la $tmpDir

echo
echo "Entre em: $tmpDir e digite:"
echo "sudo ./void-install -i"
exit 0

} # fim do wrapping




