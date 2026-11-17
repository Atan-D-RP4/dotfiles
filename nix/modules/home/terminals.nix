{ config, pkgs, ... }:

let
  dotfiles = "/home/atan/dotfiles";
in
{
  # === HYBRID: symlink existing configs, migrate to native HM as needed ===

  # Alacritty — SYMLINK existing toml (complex theme, actively edited)
  programs.alacritty = {
    enable = true;
    # SYMLINK: keep your existing config
    settings = builtins.fromTOML (builtins.readFile "${dotfiles}/prog/terminal/alacritty/alacritty.toml");
    # NATIVE: uncomment below and remove symlink when ready to own in Nix
    # settings = {
    #   window = {
    #     padding = { x = 10; y = 10; };
    #     opacity = 0.95;
    #     blur = true;
    #   };
    #   font = {
    #     size = 12.0;
    #     normal.family = "JetBrains Mono";
    #   };
    #   colors = { ... };  # Catppuccin Mocha
    # };
  };

  # Kitty — SYMLINK existing config
  programs.kitty = {
    enable = true;
    # SYMLINK: override with your config via extraConfig
    extraConfig = builtins.readFile "${dotfiles}/prog/terminal/kitty/kitty.conf";
    # NATIVE: uncomment when ready
    # settings = {
    #   font_family = "JetBrains Mono";
    #   font_size = 12.0;
    #   background_opacity = "0.95";
    #   enable_audio_bell = false;
    # };
  };

  # Ghostty — SYMLINK existing config
  programs.ghostty = {
    enable = true;
    # SYMLINK
    settings = let
      raw = builtins.readFile "${dotfiles}/prog/terminal/ghostty/config";
    in raw;
    # NATIVE: uncomment when ready
    # settings = {
    #   font-family = "JetBrains Mono";
    #   font-size = 12;
    #   background-opacity = 0.95;
    #   theme = "catppuccin-mocha";
    # };
  };

  # Foot — native (no existing config)
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrains Mono:size=12";
        pad = "10x10";
      };
      colors = {
        background = "1e1e2e";
        foreground = "cdd6f4";
        regular0 = "45475a";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "bac2de";
        bright0 = "585b70";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "a6adc8";
      };
    };
  };
}
