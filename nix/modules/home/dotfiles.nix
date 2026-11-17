{ config, pkgs, lib, ... }:

let
  dotfiles = "/home/atan/dotfiles";
in
{
  # === CORE: files not managed by specific program modules ===

  # XDG directories
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/pdf" = "zathura.desktop";
        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "video/mp4" = "mpv.desktop";
        "inode/directory" = "thunar.desktop";
      };
    };
  };

  # Core dotfiles — symlink from dotfiles repo
  xdg.configFile = {
    # Shell env (symlink, not inline)
    "shenv".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/core/shell/shenv";
    "user-dirs.dirs".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/core/shell/user-dirs";

    # lf file manager — SYMLINK existing config
    "lf/lfrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/prog/lf/lfrc";

    # ranger — SYMLINK existing config
    "ranger/rangerrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/prog/ranger/rangerrc";
    "ranger/commands.py".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/prog/ranger/commands.py";

    # ripgrep — SYMLINK or inline
    "ripgrep/config".text = ''
      --smart-case
      --hidden
      --glob '!.git/'
      --glob '!node_modules/'
      --glob '!__pycache__/'
      --glob '!.venv/'
      --glob '!result'
    '';

    # direnv — SYMLINK existing config
    "direnv/direnvrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/prog/direnv/direnvrc";
  };

  # Home directory files
  home.file = {
    # Python startup
    ".pythonstartup".text = ''
      import atexit
      import os
      import readline

      readline.parse_and_bind("tab: complete")

      history = os.path.join(os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "python", "history")
      os.makedirs(os.path.dirname(history), exist_ok=True)

      try:
          readline.read_history_file(history)
      except FileNotFoundError:
          pass

      def save_history():
          readline.write_history_file(history)

      atexit.register(save_history)
    '';
  };

  # XDG env vars
  home.sessionVariables = {
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
    XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
    XDG_DEV_HOME = "${config.home.homeDirectory}/Dev";
    XDG_TEMP_DIR = "${config.home.homeDirectory}/.tmp";
    XDG_GAMES_DIR = "${config.home.homeDirectory}/Games";
  };

  # Create directories
  home.activation.createXdgDirs = ''
    mkdir -p $HOME/.cache $HOME/.config $HOME/.local/share $HOME/.local/state $HOME/.local/bin
    mkdir -p $HOME/Dev $HOME/.tmp $HOME/Games
    mkdir -p $HOME/Documents $HOME/Downloads $HOME/Music $HOME/Pictures $HOME/Videos $HOME/Desktop
  '';

  # Fonts
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrains Mono" "Fira Code" ];
      sansSerif = [ "Noto Sans" "Liberation Sans" ];
      serif = [ "Noto Serif" "Liberation Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
