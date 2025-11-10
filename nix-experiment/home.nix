{ config, pkgs, ... }:

{
  home.username = "atan";
  home.homeDirectory = "/home/atan";

  imports = [
    ./git.nix
    ./tmux.nix
    ./shell.nix
  ];

  home.packages = [
    pkgs.fzf
  ];

  programs.home-manager.enable = true;
}