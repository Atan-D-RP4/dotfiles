link "$XDG_CONFIG_HOME/nvim/init.vim"
link-to "$XDG_CONFIG_HOME/nvim/" ./nvim_conf/lazy-lock.json
link-to "$XDG_CONFIG_HOME/nvim/" ./nvim_conf/init.lua
link-to "$XDG_CONFIG_HOME/nvim/doc" ./nvim_conf/doc/*
link-to "$XDG_CONFIG_HOME/nvim/lua" ./nvim_conf/lua/*
link-to "$XDG_CONFIG_HOME/nvim/ftplugin" ./nvim_conf/ftplugin/*

# Core app
packages \
	paru:neovim-nightly-bin,english-wordnet,wordnet-progs \
	yay:neovim-git,english-wordnet,wordnet-progs \
	pacman:neovim-git,

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
