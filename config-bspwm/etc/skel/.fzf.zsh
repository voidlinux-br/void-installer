# Setup fzf
# ---------
if [[ ! "$PATH" == */root/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/root/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/share/fzf/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/usr/share/fzf/key-bindings.zsh"
