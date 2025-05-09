#!/bin/zsh
#
# .zshrc - Zsh file loaded on interactive shell sessions.
#

# Zsh options.
setopt extended_glob

# Autoload functions you might want to use with antidote.
ZFUNCDIR=${ZFUNCDIR:-$ZDOTDIR/functions}
fpath=($ZFUNCDIR $fpath)
autoload -Uz $fpath[1]/*(.:t)

# Source zstyles you might use with antidote.
[[ -e ${ZDOTDIR:-~}/zstyles ]] && source ${ZDOTDIR:-~}/zstyles

# Clone antidote if necessary.
[[ -d ${ZDOTDIR:-~}/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote ${ZDOTDIR:-~}/.antidote

# Create an amazing Zsh config using antidote plugins.
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# set omz variables
# This here is inlined for a small startup time improvement
#ZSH=$(antidote path ohmyzsh/ohmyzsh)
ZSH="$HOME"/.cache/antidote/ohmyzsh/ohmyzsh
# https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#completions-are-not-loaded-when-using-a-plugin-manager
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
mkdir -p "$ZSH_CACHE_DIR/completions"
fpath=("$ZSH_CACHE_DIR/completions" $fpath)


[[ -e ${ZDOTDIR:-~}/local-machine-conf ]] && source ${ZDOTDIR:-~}/local-machine-conf
 
#### NOW LOAD ANTIDOTE

antidote load

# Finally
export EDITOR="${EDITOR:-nvim}"
export GPG_TTY=$(tty)
export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && zsh-defer source "$HOME/.sdkman/bin/sdkman-init.sh"

