#
# ~/.bash_profile
#

if command -v hostnamectl; then
    hostnamectl
fi
timenow="$(date +'%H:%M')"
load="$(awk '{print $1 ", " $2 ", " $3}' /proc/loadavg)"

printf '\e[0;35m%s\n\e[0m' "$logo"
printf 'Welcome back! The time now is %s UTC\n' "$timenow"
printf 'Server load    :  %s\n' "$load"
printf 'Server Uptime  : %s\n' "$(uptime)"
printf 'User           :  %s %s\n' "$(whoami)" "$(id)"
printf '\n'

[[ -f ~/.bashrc ]] && . ~/.bashrc

#if [[ -z "$DISPLAY" ]]; then
#	exec startx &
#	exec start lxmd &
#fi

