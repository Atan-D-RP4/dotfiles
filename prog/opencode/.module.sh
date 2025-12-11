packages paru:opencode-bin

# Link configuration file
link "$XDG_CONFIG_HOME/opencode/opencode.jsonc"

# Link directories directly - directory symlinks automatically include all
# existing and future files without needing to re-run the linking process
link tool:"$XDG_CONFIG_HOME/opencode/tool" \
	agent:"$XDG_CONFIG_HOME/opencode/agent" \
	command:"$XDG_CONFIG_HOME/opencode/command" \
	templates:"$XDG_CONFIG_HOME/opencode/templates"

link "$XDG_CONFIG_HOME/opencode/node_modules":node_modules
