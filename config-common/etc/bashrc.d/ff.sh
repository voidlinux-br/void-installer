#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1091,SC2039,SC2166

function ff() {
    local filepath=$1
    local num_arquivos=$2
    local intervalo=$3
    local resultado

    if [ $# -eq 0 ]; then
        filepath='*.*'
    fi

    local find_command="sudo find . -type d -name .git -prune -o -type f,l -iname '$filepath'"

    if [[ -n "$intervalo" ]]; then
        find_command+=" -mmin -${intervalo}"
    fi

    local format_string="\033[1;32m%TY-%Tm-%Td %TH:%TM:%TS\033[0m \033[1;34m%p\033[0m\n"
    find_command+=" -printf \"$format_string\" | sort"

    if [[ -n "$num_arquivos" ]]; then
        find_command+=" | tail -n $num_arquivos"
    fi

    resultado=$(eval "$find_command")
    echo "=== Resultado ==="
    echo "$resultado" | nl
    echo "=== Parâmetros informados ==="
    echo "Searching              : ${green}($find_command)${reset}"
    echo "Padrão             (\$1): ${filepath}"
    echo "Número de arquivos (\$2): ${num_arquivos:-Todos}"
    echo "Intervalo de tempo (\$3): ${intervalo:-Todos} (minutos)"
    echo "Uso: ${red}ff "*.c"${reset} or ${red}ff "*.c" 10 | xargs commando${reset} or ${red}ff "*.c" | xargs cp -v /tmp${reset}"
}
export -f ff
