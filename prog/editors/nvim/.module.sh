link "$XDG_CONFIG_HOME/nvim/init.vim"
link-to "$XDG_CONFIG_HOME/nvim/" ./nvim_conf/lazy-lock.json
link-to "$XDG_CONFIG_HOME/nvim/" ./nvim_conf/init.lua
link-to "$XDG_CONFIG_HOME/nvim/doc" ./nvim_conf/doc/*
link-to "$XDG_CONFIG_HOME/nvim/lua" ./nvim_conf/lua/*
link-to "$XDG_CONFIG_HOME/nvim/ftplugin" ./nvim_conf/ftplugin/*

packages                                      \
  apt:neovim                                  \
  yay:neovim-git			      \
  pacman:neovim
