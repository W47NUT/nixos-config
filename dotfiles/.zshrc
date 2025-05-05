# Lines configured by zsh-newuser-install
# HISTFILE=~/.local/share/zsh/histfile
HISTSIZE=5000
SAVEHIST=5000
setopt autocd extendedglob notify
bindkey -v
alias ls="lsd"
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/w47nut/.zshrc'

export MANPAGER='nvim +Man!'
export PAGER='nvim +Man!'
export LS_COLORS="$(vivid generate molokai)"
export RANGER_LOAD_DEFAULT_RC=FALSE

# Ensure our NixOS system profile is in our PATH
export PATH="/run/current-system/profile/bin:$PATH"

autoload -Uz compinit
compinit
# End of lines added by compinstall

eval "$(starship init zsh)"
