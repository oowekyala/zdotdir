# This dir is put in fpath by zephyr/completions plugin
# This wrapper script acts as a plugin that defines autoloaded completions without calling compinit

autoload -Uz _just
compdef _just just

# Compdef for MLIR
# Note that some of the options listed are bullshit as they are pass parameters
# compdef _gnu_generic cinm-opt mlir-opt tilefirst-opt
compdef _mlir_opt_comp tilefirst-opt mlir-opt cinm-opt