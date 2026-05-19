# This dir is put in fpath by zephyr/completions plugin
# This wrapper script acts as a plugin that defines autoloaded completions without calling compinit

# Per-recipe just completions: add just/ subdir to fpath and autoload all _just_* functions from it
fpath=("${0:h}/just" $fpath)
autoload -Uz "${0:h}"/just/_just_*(.:t)

autoload -Uz _just
