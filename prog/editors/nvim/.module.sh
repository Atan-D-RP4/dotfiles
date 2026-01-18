link "$XDG_CONFIG_HOME/nvim/init.vim"
link-to "$XDG_CONFIG_HOME/nvim/" ./nvim_conf/lazy-lock.json
link-to "$XDG_CONFIG_HOME/nvim/" ./nvim_conf/init.lua
link-to "$XDG_CONFIG_HOME/nvim/doc" ./nvim_conf/doc/*
link-to "$XDG_CONFIG_HOME/nvim/lua" ./nvim_conf/lua/*
link-to "$XDG_CONFIG_HOME/nvim/ftplugin" ./nvim_conf/ftplugin/*

# Core app
packages \
	paru:neovim-nightly-bin \
	yay:neovim-git \
	pacman:neovim-git,

# English wordnet tools for dictionary lookups
packages \
	paru:english-wordnet,wordnet-progs \
	yay:english-wordnet,wordnet-progs

# Lua tools
packages \
	paru:emmylua-ls-bin,stylua \
	yay:emmylua-ls-bin,stylua \
	pacman:lua-language-server,stylua

# Shell tools
packages \
	paru:shfmt,shellcheck \
	yay:shfmt,shellcheck \
	pacman:shfmt,shellcheck

# Check if matugen is installed
if command -v matugen &>/dev/null; then
	info 'Configuring matugen...'
	# Check if matugen config file exists
	if [ -f "$XDG_CONFIG_HOME/matugen/config.toml" ]; then
		# Check if matugen.toml contents are already in config.toml
		if grep -qF '[template.nvim-base16]' "$XDG_CONFIG_HOME/matugen/config.toml"; then
			warn 'matugen.toml contents already exist in config.toml, skipping...'
		else
			# Append ./matugen.toml contents to the existing config.toml
			cat ./matugen.toml >>"$XDG_CONFIG_HOME/matugen/config.toml"
		fi
	else
		# Create the matugen config directory if it doesn't exist
		mkdir -p "$XDG_CONFIG_HOME/matugen"
		echo '[config]' >"$XDG_CONFIG_HOME/matugen/config.toml"
		# Copy the matugen config file to the user's config directory
		cat ./matugen.toml >>"$XDG_CONFIG_HOME/matugen/config.toml"
	fi
fi
