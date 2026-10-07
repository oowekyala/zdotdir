#!/bin/zsh
# SDKMAN (Java/Scala versions). Load it with kind:defer in zsh_plugins.txt: it
# runs after .zshrc, so its candidate dirs still end up first on PATH, which is
# what the installer's "must be at the end of the file" note is about.
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
