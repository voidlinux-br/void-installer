export LANG=pt_BR.utf8
source ~/.git-prompt.sh

function be_get_branch {
  local dir="$PWD"
  local vcs
  local nick
  while [[ "$dir" != "/" ]]; do
    for vcs in git hg svn bzr; do
      if [[ -d "$dir/.$vcs" ]] && hash "$vcs" &>/dev/null; then
        case "$vcs" in
          git) __git_ps1 "${1:-(%s) }"; return;;
          hg) nick=$(hg branch 2>/dev/null);;
          svn) nick=$(svn info 2>/dev/null\
                | grep -e '^Repository Root:'\
                | sed -e 's#.*/##');;
          bzr)
            local conf="${dir}/.bzr/branch/branch.conf" # normal branch
            [[ -f "$conf" ]] && nick=$(grep -E '^nickname =' "$conf" | cut -d' ' -f 3)
            conf="${dir}/.bzr/branch/location" # colo/lightweight branch
            [[ -z "$nick" ]] && [[ -f "$conf" ]] && nick="$(basename "$(< $conf)")"
            [[ -z "$nick" ]] && nick="$(basename "$(readlink -f "$dir")")";;
        esac
        [[ -n "$nick" ]] && printf "${1:-(%s) }" "$nick"
        return 0
      fi
    done
    dir="$(dirname "$dir")"
  done
}

## Add branch to PS1 (based on $PS1 or $1), formatted as $2
export GIT_PS1_SHOWDIRTYSTATE=yes
export PS1="\$(be_get_branch "$2")${PS1}";

function color_my_prompt {
    local __user_and_host="\[\033[01;32m\]\u@\h"
    local __cur_location="\[\033[01;34m\]\w"
    local __git_branch_color="\[\033[31m\]"
    #local __git_branch="\`ruby -e \"print (%x{git branch 2> /dev/null}.grep(/^\*/).first || '').gsub(/^\* (.+)$/, '(\1) ')\"\`"
    local __git_branch='`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`'
    local __prompt_tail="\[\033[35m\]"
    local __last_color="\[\033[00m\]"
    export PS1="$__user_and_host $__cur_location $__git_branch_color$__git_branch$__prompt_tail$__last_color \n#"
}
#color_my_prompt
#export PS1="\n\[\e[1;37m\]|-- \[\e[1;32m\]\u\[\e[0;39m\]@\[\e[1;36m\]\h\[\e[0;39m\]:\[\e[1;33m\]\w\[\e[0;39m\]\[\e[1;35m\]$(__git_ps1 " (%s)")\[\e[0;39m\] \[\e[1;37m\]--|\[\e[0;39m\]\n$"
#PS1='\e];\s\a\n\e[33m\w \e[36m$(pc)\e[m\n$ '

# Recomendo a instalação do fonts-powerline
# sudo apt-get install fonts-powerline
# sudo pacman -S powerline-fonts
# https://github.com/powerline/fonts
############################################################################
####                          CUSTOMIZAR BASH                           ####
## copie este cógigo e cole no final do seu arquivo *.bashrc* na sua home ##
bash_prompt_command() {
	local pwdmaxlen=25
	local trunc_symbol=".."
	local dir=${PWD##*/}
	pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
	NEW_PWD=${PWD/#$HOME/\~}
	GIT_BRANCH="$(__git_ps1 " (%s)")"
	local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))

	if [ ${pwdoffset} -gt "0" ]
	then
		NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
		NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
	fi
}

format_font()
{
	## FIRST ARGUMENT TO RETURN FORMAT STRING
	local output=$1

	case $# in
	2)	eval $output="'\[\033[0;${2}m\]'"	;;
	3)	eval $output="'\[\033[0;${2};${3}m\]'"		;;
	4)	eval $output="'\[\033[0;${2};${3};${4}m\]'"		;;
	*)	eval $output="'\[\033[0m\]'"	;;
	esac
}

bash_prompt() {
	## FONT EFFECT
	local      NONE='0'
	local      BOLD='1'
	local       DIM='2'
	local UNDERLINE='4'
	local     BLINK='5'
	local    INVERT='7'
	local    HIDDEN='8'

	## COLORS
	local   DEFAULT='9'
	local     BLACK='0'
	local       RED='1'
	local     GREEN='2'
	local    YELLOW='3'
	local      BLUE='4'
	local   MAGENTA='5'
	local      CYAN='6'
	local    L_GRAY='7'
	local    D_GRAY='60'
	local     L_RED='61'
	local   L_GREEN='62'
	local  L_YELLOW='63'
	local    L_BLUE='64'
	local L_MAGENTA='65'
	local    L_CYAN='66'
	local     WHITE='67'

	## TYPE
	local     RESET='0'
	local    EFFECT='0'
	local     COLOR='30'
	local        BG='40'

	## 256 COLOR CODES
	local NO_FORMAT="\[\033[0m\]"
	local ORANGE_BOLD="\[\033[1;38;5;208m\]"
	local TOXIC_GREEN_BOLD="\[\033[1;38;5;118m\]"
	local RED_BOLD="\[\033[1;38;5;1m\]"
	local CYAN_BOLD="\[\033[1;38;5;87m\]"
	local BLACK_BOLD="\[\033[1;38;5;0m\]"
	local WHITE_BOLD="\[\033[1;38;5;15m\]"
	local GRAY_BOLD="\[\033[1;90m\]"
	local BLUE_BOLD="\[\033[1;38;5;74m\]"

	############################################################################
	## CONFIGURATION                                                          ##
	## Escolha sua configuração de cores aqui                                 ##
	############################################################################

	## DEFAUT
	#FONT_COLOR_1=$WHITE; BACKGROUND_1=$BLUE; TEXTEFFECT_1=$BOLD
	#FONT_COLOR_2=$WHITE; BACKGROUND_2=$L_BLUE; TEXTEFFECT_2=$BOLD
	#FONT_COLOR_3=$D_GRAY; BACKGROUND_3=$WHITE; TEXTEFFECT_3=$BOLD
	#PROMT_FORMAT=$BLUE_BOLD

  if (( EUID == 0 )); then
      # ## RED-BLACK
      FONT_COLOR_1=$WHITE; BACKGROUND_1=$RED; TEXTEFFECT_1=$BOLD
      FONT_COLOR_2=$WHITE; BACKGROUND_2=$D_GRAY; TEXTEFFECT_2=$BOLD
      FONT_COLOR_3=$WHITE; BACKGROUND_3=$BLUE; TEXTEFFECT_3=$BOLD
      PROMT_FORMAT=$TOXIC_GREEN_BOLD

		# ## RED-BLACK
		#FONT_COLOR_1=$WHITE; BACKGROUND_1=$RED; TEXTEFFECT_1=$BOLD
		#FONT_COLOR_2=$WHITE; BACKGROUND_2=$D_GRAY; TEXTEFFECT_2=$BOLD
		#FONT_COLOR_3=$WHITE; BACKGROUND_3=$BLUE; TEXTEFFECT_3=$BOLD
		#PROMT_FORMAT=$TOXIC_GREEN_BOLD

	 	## DEFAUT
#		FONT_COLOR_1=$WHITE; BACKGROUND_1=$BLUE; TEXTEFFECT_1=$BOLD
#	   FONT_COLOR_2=$WHITE; BACKGROUND_2=$L_BLUE; TEXTEFFECT_2=$BOLD
#		FONT_COLOR_3=$D_GRAY; BACKGROUND_3=$WHITE; TEXTEFFECT_3=$BOLD
#	   PROMT_FORMAT=$BLUE_BOLD
	else
		# ## GREEN-WHITE
		FONT_COLOR_1=$WHITE; BACKGROUND_1=$GREEN; TEXTEFFECT_1=$BOLD
		FONT_COLOR_2=$D_GRAY; BACKGROUND_2=$L_GREEN; TEXTEFFECT_2=$BOLD
		FONT_COLOR_3=$D_GRAY; BACKGROUND_3=$WHITE; TEXTEFFECT_3=$BOLD
		PROMT_FORMAT=$TOXIC_GREEN_BOLD
	fi

	# ## CYAN-BLUE
	# FONT_COLOR_1=$WHITE; BACKGROUND_1=$CYAN; TEXTEFFECT_1=$BOLD
	# FONT_COLOR_2=$WHITE; BACKGROUND_2=$L_BLUE; TEXTEFFECT_2=$BOLD
	# FONT_COLOR_3=$WHITE; BACKGROUND_3=$BLUE; TEXTEFFECT_3=$BOLD
	# PROMT_FORMAT=$BLUE_BOLD

	# ## GRAY-SCALE
	# FONT_COLOR_1=$WHITE; BACKGROUND_1=$BLACK; TEXTEFFECT_1=$BOLD
	# FONT_COLOR_2=$WHITE; BACKGROUND_2=$D_GRAY; TEXTEFFECT_2=$BOLD
	# FONT_COLOR_3=$BLACK; BACKGROUND_3=$L_GRAY; TEXTEFFECT_3=$BOLD
	# PROMT_FORMAT=$WHITE_BOLD

	# ## GRAY-CYAN
	# FONT_COLOR_1=$WHITE; BACKGROUND_1=$GREEN; TEXTEFFECT_1=$BOLD
	# FONT_COLOR_2=$GRAY; BACKGROUND_2=$L_GREEN; TEXTEFFECT_2=$BOLD
	# FONT_COLOR_3=$WHITE; BACKGROUND_3=$GREEN; TEXTEFFECT_3=$BOLD
	# PROMT_FORMAT=$TOXIC_GREEN_BOLD

	# ## MAGENTA-WHITE
	# FONT_COLOR_1=$WHITE; BACKGROUND_1=$MAGENTA; TEXTEFFECT_1=$BOLD
	# FONT_COLOR_2=$WHITE; BACKGROUND_2=$L_MAGENTA; TEXTEFFECT_2=$BOLD
	# FONT_COLOR_3=$D_GRAY; BACKGROUND_3=$WHITE; TEXTEFFECT_3=$BOLD
	# PROMT_FORMAT=$WHITE_BOLD

	# ## BLUE-ORANGE
	# FONT_COLOR_1=$WHITE; BACKGROUND_1=$L_BLUE; TEXTEFFECT_1=$BOLD
	# FONT_COLOR_2=$WHITE; BACKGROUND_2=$YELLOW; TEXTEFFECT_2=$BOLD
	# FONT_COLOR_3=$D_GRAY; BACKGROUND_3=$WHITE; TEXTEFFECT_3=$BOLD
	# PROMT_FORMAT=$BLUE_BOLD

	# ## PINK-WHITE
	# FONT_COLOR_1=$WHITE; BACKGROUND_1=$RED; TEXTEFFECT_1=$BOLD
	# FONT_COLOR_2=$WHITE; BACKGROUND_2=$L_RED; TEXTEFFECT_2=$BOLD
	# FONT_COLOR_3=$D_GRAY; BACKGROUND_3=$WHITE; TEXTEFFECT_3=$BOLD
	# PROMT_FORMAT=$RED_BOLD

	# ## GREY-BLUE
	# FONT_COLOR_1=$WHITE; BACKGROUND_1=$D_GRAY; TEXTEFFECT_1=$BOLD
	# FONT_COLOR_2=$WHITE; BACKGROUND_2=$L_BLUE; TEXTEFFECT_2=$BOLD
	# FONT_COLOR_3=$D_GRAY; BACKGROUND_3=$WHITE; TEXTEFFECT_3=$BOLD
	# PROMT_FORMAT=$BLUE_BOLD

	# ## GREEN-WHITE
	# FONT_COLOR_1=$WHITE; BACKGROUND_1=$GREEN; TEXTEFFECT_1=$BOLD
	# FONT_COLOR_2=$D_GRAY; BACKGROUND_2=$L_GREEN; TEXTEFFECT_2=$BOLD
	# FONT_COLOR_3=$D_GRAY; BACKGROUND_3=$WHITE; TEXTEFFECT_3=$BOLD
	# PROMT_FORMAT=$TOXIC_GREEN_BOLD

	############################################################################
	## TEXT FORMATING                                                         ##
	## Generate the text formating according to configuration                 ##
	############################################################################

	## CONVERT CODES: add offset
	FC1=$(($FONT_COLOR_1+$COLOR))
	BG1=$(($BACKGROUND_1+$BG))
	FE1=$(($TEXTEFFECT_1+$EFFECT))

	FC2=$(($FONT_COLOR_2+$COLOR))
	BG2=$(($BACKGROUND_2+$BG))
	FE2=$(($TEXTEFFECT_2+$EFFECT))

	FC3=$(($FONT_COLOR_3+$COLOR))
	BG3=$(($BACKGROUND_3+$BG))
	FE3=$(($TEXTEFFECT_3+$EFFECT))

	FC4=$(($FONT_COLOR_4+$COLOR))
	BG4=$(($BACKGROUND_4+$BG))
	FE4=$(($TEXTEFFECT_4+$EFFECT))

	## CALL FORMATING HELPER FUNCTION: effect + font color + BG color
	local TEXT_FORMAT_1
	local TEXT_FORMAT_2
	local TEXT_FORMAT_3
	local TEXT_FORMAT_4
	format_font TEXT_FORMAT_1 $FE1 $FC1 $BG1
	format_font TEXT_FORMAT_2 $FE2 $FC2 $BG2
	format_font TEXT_FORMAT_3 $FC3 $FE3 $BG3
	format_font TEXT_FORMAT_4 $FC4 $FE4 $BG4

	# GENERATE PROMT SECTIONS
	local PROMT_USER=$"$TEXT_FORMAT_1 \u "
	local PROMT_HOST=$"$TEXT_FORMAT_2 \h "
	local PROMT_PWD=$"$TEXT_FORMAT_3 \${NEW_PWD} \${GIT_BRANCH} "
	local PROMT_INPUT=$"$PROMT_FORMAT "

	############################################################################
	## SEPARATOR FORMATING                                                    ##
	## Generate the separators between sections                               ##
	## Uses background colors of the sections                                 ##
	############################################################################

	## CONVERT CODES
	TSFC1=$(($BACKGROUND_1+$COLOR))
	TSBG1=$(($BACKGROUND_2+$BG))

	TSFC2=$(($BACKGROUND_2+$COLOR))
	TSBG2=$(($BACKGROUND_3+$BG))

	TSFC3=$(($BACKGROUND_3+$COLOR))
	TSBG3=$(($DEFAULT+$BG))

	## CALL FORMATING HELPER FUNCTION: effect + font color + BG color
	local SEPARATOR_FORMAT_1
	local SEPARATOR_FORMAT_2
	local SEPARATOR_FORMAT_3
	format_font SEPARATOR_FORMAT_1 $TSFC1 $TSBG1
	format_font SEPARATOR_FORMAT_2 $TSFC2 $TSBG2
	format_font SEPARATOR_FORMAT_3 $TSFC3 $TSBG3

	## GENERATE SEPARATORS WITH FANCY TRIANGLE
	#local TRIANGLE=$'🐷 '
	local TRIANGLE=$'\uE0B0'
	local SEPARATOR_1=$SEPARATOR_FORMAT_1$TRIANGLE
	local SEPARATOR_2=$SEPARATOR_FORMAT_2$TRIANGLE
	local SEPARATOR_3=$SEPARATOR_FORMAT_3$TRIANGLE

	############################################################################
	## WINDOW TITLE                                                           ##
	## Prevent messed up terminal-window titles                               ##
	############################################################################
	case $TERM in
	xterm*|rxvt*) 	local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]'	;;
	*)					local TITLEBAR=""	;;
	esac

	PS1="$TITLEBAR\n${PROMT_USER}${SEPARATOR_1}${PROMT_HOST}${SEPARATOR_2}${PROMT_PWD}${SEPARATOR_3}${PROMT_INPUT}"
	none="$(tput sgr0)"
	trap 'echo -ne "${none}"' DEBUG
}

PROMPT_COMMAND=bash_prompt_command
bash_prompt
unset bash_prompt
