#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1091,SC2039,SC2166

ffs() {
    [ "$1" ] || {
        echo "Uso: ffs 'search' '*.doc' | xargs comando"
        echo "     ffs 'def |function ' '*.prg'"
        echo "     ffs '#include' '*.*'"
        echo "     ffs 'search|search|texto' '*.txt' | xargs rm -fv"
        echo "     ffs 'ELF|ASCII|MP4' '*.doc' | xargs cp -v /tmp"
        return
    }
    #   sudo find . -type f -iname '*'"$2"'*' -exec grep --text -iE "($1)" {} +;
    #   sudo grep -r --color=auto -n -iE "($1)" $2;
    #   sudo find . -type d -name bcc-archived -prune -o -type f -iname '*'"$2"'*' -exec grep --color=auto -n -iE "($1)" {} +;
    sudo find . -type d -name bcc-archived -prune -o -type f \( -iname '*'"$2"'*' -and ! -iname '*.pot' -and ! -iname '*.mo' -and ! -iname '*.po' \) -exec grep --color=auto -n -iE "($1)" {} +
}
export -f ffs

