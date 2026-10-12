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
# This command is inlined for a small startup time improvement (avoids launching a subshell to run `antidote`)
#ZSH=$(antidote path ohmyzsh/ohmyzsh)
ZSH="$HOME"/.cache/antidote/ohmyzsh/ohmyzsh
# https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#completions-are-not-loaded-when-using-a-plugin-manager
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
[[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"
fpath=("$ZSH_CACHE_DIR/completions" $fpath)


# This can contain zstyles, custom paths, env vars and such.
# Load it before loading plugins.
[[ -e ${ZDOTDIR:-~}/local-machine-conf ]] && source ${ZDOTDIR:-~}/local-machine-conf

# Tools pixi installs globally -- direnv among them. Before the plugins,
# because the oh-my-zsh direnv plugin is what installs direnv's hook and it
# looks for the binary as it loads: put this after `antidote load` and the
# plugin prints "direnv not found" and hooks nothing.
[[ -d "$HOME/.pixi/bin" ]] && path+=("$HOME/.pixi/bin")
# Same for cargo.
[[ -d "$HOME/.cargo/bin" ]] && path+=("$HOME/.cargo/bin")

#### NOW LOAD ANTIDOTE

antidote load

#### FINALLY

export GPG_TTY=$TTY

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# The p10k wizard writes xterm-256 colors, which ignore the terminal theme;
# scripts/p10k-theme-colors converts them. Warns once, at the first prompt
# (instant prompt objects to output during startup), if they're back.
_p10k_theme_colors_check() {
  add-zsh-hook -d precmd _p10k_theme_colors_check
  if grep -qE 'POWERLEVEL9K_[A-Za-z0-9_{},]*(FOREGROUND|BACKGROUND|COLOR)=(1[6-9]|[2-9][0-9]|[12][0-9]{2})\b|%(1[6-9]|[2-9][0-9]|[12][0-9]{2})[FK]' \
      ~/.config/zsh/.p10k.zsh 2>/dev/null; then
    print -P "%F{3}.p10k.zsh uses colors outside the terminal theme: run ${ZDOTDIR:-~}/scripts/p10k-theme-colors%f"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _p10k_theme_colors_check

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi

function profilerc {
   time ZSH_DEBUGRC=1 zsh -i -c exit
}
