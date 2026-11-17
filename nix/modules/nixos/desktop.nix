{ config, pkgs, ... }:

{
  # Desktop environment (adjust based on your needs)
  # Option 1: Hyprland (Wayland)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Option 2: KDE Plasma
  # services.desktopManager.plasma6.enable = true;

  # Option 3: GNOME
  # services.xserver.desktopManager.gnome.enable = true;

  # Display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # X11
  services.xserver = {
    enable = true;
    layout = "gb";
    xkbVariant = "";
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Graphics
  hardware.graphics = {
    enable = true;
  };

  # NVIDIA (if applicable)
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   powerManagement.finegrained = false;
  #   open = false;
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts
      dina-font
      proggyfonts
      (pkgs.nerd-fonts.jetbrains-mono)
      (pkgs.nerd-fonts.fira-code)
    ];
    fontDir.enable = true;
  };

  # Screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Environment variables for Wayland
  environment.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  # Polkit (for privilege escalation prompts)
  security.polkit.enable = true;

  # Thunar file manager
  programs.thunar.enable = true;
  services.tumbler.enable = true;
}
