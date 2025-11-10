{ config, pkgs, ... }:

{
  home.packages = [ pkgs.git ];

  home.file.".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "/home/atan/dotfiles/prog/git/gitconfig";
}