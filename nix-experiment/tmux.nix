{ config, pkgs, ... }:

{
  home.packages = [ pkgs.tmux ];

  home.file.".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/atan/dotfiles/prog/tmux/tmuxrc";
}