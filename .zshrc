#!/bin/zsh
#
# .zshrc - Zsh file loaded on interactive shell sessions.
#

# Zsh options.
setopt extended_glob

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi


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

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# set omz variables
# This here is inlined for a small startup time improvement
#ZSH=$(antidote path ohmyzsh/ohmyzsh)
ZSH="$HOME"/.cache/antidote/ohmyzsh/ohmyzsh
# https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#completions-are-not-loaded-when-using-a-plugin-manager
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
export ZSH_CUSTOM=$ZDOTDIR/custom
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
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && zsh-defer source "$SDKMAN_DIR/bin/sdkman-init.sh"


function init_conda() {
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
}

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi

function profilerc {
   time ZSH_DEBUGRC=1 zsh -i -c exit
}



