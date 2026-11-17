{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
  ];

  # System identity
  networking.hostName = "atan";
  
  # Time zone
  time.timeZone = "Europe/London";

  # Select internationalisation properties
  i18n.defaultLocale = "en_GB.UTF-8";

  # Boot loader (adjust for your system)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;

  # Define user
  users.users.atan = {
    isNormalUser = true;
    description = "Atan";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # Enable zsh for system
  programs.zsh.enable = true;

  # System packages (minimal - most go in home-manager)
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
  ];

  # Docker
  virtualisation.docker.enable = true;

  # SSH
  services.openssh.enable = true;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  # This value determines the NixOS release
  system.stateVersion = "25.05";
}
