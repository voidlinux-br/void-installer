# Use powerline
USE_POWERLINE="true"
# Source biglinux-zsh-configuration
if [[ -e /usr/share/zsh/biglinux-zsh-config ]]; then
  source /usr/share/zsh/biglinux-zsh-config
fi
# Use biglinux zsh prompt
if [[ -e /usr/share/zsh/biglinux-zsh-prompt ]]; then
  source /usr/share/zsh/biglinux-zsh-prompt
fi
# User aliases
if [[ -e ~/.bash_aliases ]]; then
  source ~/.bash_aliases
fi
