{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/shell.nix
    ./modules/home/editors.nix
    ./modules/home/terminals.nix
    ./modules/home/dev.nix
    ./modules/home/dotfiles.nix
  ];

  # Home Manager settings
  home = {
    username = "atan";
    homeDirectory = "/home/atan";
    stateVersion = "25.05";

    # Packages
    packages = with pkgs; [
      # Core utilities
      ripgrep
      fd
      bat
      eza
      fzf
      jq
      yq-go
      tree
      htop
      bottom
      unzip
      p7zip
      trash-cli
      tldr

      # File management
      nnn
      lf

      # Network
      nmap
      dig
      traceroute

      # Development
      python3
      nodejs
      go
      cargo
      rustc

      # Media
      imv
      mpv
      vlc

      # System
      pciutils
      usbutils
      lsof
      strace
    ];

    # Session variables
    sessionVariables = {
      EDITOR = "nvim";
      PAGER = "less";
      LESS = "-R";
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --info=inline";
    };

    # Hush login
    file.".hushlogin".text = "";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
