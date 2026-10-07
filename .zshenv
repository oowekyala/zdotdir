#!/bin/zsh
#
# .zshenv - Zsh environment file, loaded always.
#

# NOTE: .zshenv needs to live at ~/.zshenv, not in $ZDOTDIR!

# Set ZDOTDIR if you want to re-home Zsh.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}
export ZSH_CUSTOM=$ZDOTDIR/custom
# Here rather than in .zshrc so non-interactive shells (scripts, `ssh host cmd`)
# use the same keyring and agent. Graphical sessions get it from home-manager.
export GNUPGHOME=${GNUPGHOME:-$XDG_CONFIG_HOME/gnupg}

# Where this machine's conda lives, for init_conda in .zshrc. Found rather
# than named, since the install goes in a different place on each machine and
# this file is shared between them. Most specific first: a per-user install
# takes precedence over a system-wide one. Already set wins, so a machine with
# it somewhere else can say so in local-machine-conf.
if [[ -z $CONDA_HOME ]]; then
  for _conda_home in \
      $HOME/miniconda3 $HOME/miniforge3 $HOME/mambaforge $HOME/anaconda3 \
      /opt/miniconda3 /opt/miniforge3 /opt/conda
  do
    if [[ -d $_conda_home ]]; then
      export CONDA_HOME=$_conda_home
      break
    fi
  done
  unset _conda_home
fi


# https://www.johnhawthorn.com/2012/09/vi-escape-delays/
KEYTIMEOUT=1

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath