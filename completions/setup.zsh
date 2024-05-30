# This dir is put in fpath by zephyr/completions plugin
# This wrapper script acts as a plugin that defines autoloaded completions without calling compinit

autoload -Uz _just
compdef _just just
