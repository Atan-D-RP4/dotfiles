{ config, pkgs, ... }:

{
  # System packages
  environment.systemPackages = with pkgs; [
    # Core
    vim
    wget
    curl
    git
    unzip
    p7zip
    
    # System monitoring
    htop
    bottom
    lsof
    
    # Network
    networkmanager
    
    # Development
    gcc
    gnumake
    
    # Nix
    nix-index
  ];

  # Enable zsh as default shell
  programs.zsh.enable = true;

  # Enable git
  programs.git.enable = true;

  # Enable fish (optional)
  programs.fish.enable = true;

  # Systemd services
  systemd.services = {
    # Example: custom service
    # my-service = {
    #   description = "My custom service";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.my-tool}/bin/my-tool";
    #   };
    # };
  };

  # Environment variables
  environment.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Time zone
  time.timeZone = "Europe/London";

  # Internationalisation
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Console
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
    # Or use services.xserver.layout = "gb";
  };
}
