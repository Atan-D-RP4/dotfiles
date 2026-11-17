{ config, pkgs, ... }:

let
  dotfiles = "/home/atan/dotfiles";
in
{
  # === HYBRID: symlink existing configs, migrate to native HM as needed ===

  # Bash — start with existing bashrc, migrate to native options later
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # SYMLINK: keeps your existing bashrc intact, edit it directly
    bashrcExtra = builtins.readFile "${dotfiles}/prog/shells/bash/bashrc";
    profileExtra = builtins.readFile "${dotfiles}/prog/shells/bash/profile";
    # NATIVE: uncomment below and remove reads above when ready to own in Nix
    # shellAliases = { ".." = "cd .."; };
    # sessionVariables = { EDITOR = "nvim"; };
    # initExtra = ''source ${dotfiles}/core/shell/shenv'';
  };

  # Zsh — start with existing zshrc
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # SYMLINK
    initExtra = builtins.readFile "${dotfiles}/prog/shells/zsh/zshrc";
    envExtra = builtins.readFile "${dotfiles}/prog/shells/zsh/zshenv";
    # NATIVE: uncomment when ready
    # shellAliases = { g = "git"; gs = "git status"; };
    # sessionVariables = { EDITOR = "nvim"; };
    # plugins = [ { name = "zsh-autosuggestions"; src = pkgs.zsh-autosuggestions; } ];
  };

  # Fish — start with existing config
  programs.fish = {
    enable = true;
    # SYMLINK
    shellInit = builtins.readFile "${dotfiles}/prog/shells/fish/config.fish";
    # NATIVE: uncomment when ready
    # shellAliases = { g = "git"; };
    # functions = { mkcd = "mkdir -p $argv[1] && cd $argv[1]"; };
  };

  # Starship — native only (no existing config to symlink)
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      git_branch.style = "bold purple";
      git_status.style = "bold red";
      nix_shell = {
        style = "bold green";
        symbol = " ";
      };
    };
  };

  # FZF — native
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--info=inline"
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
    ];
  };

  # Direnv — native
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # Zoxide — native
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # Eza — native
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    git = true;
    icons = "auto";
  };

  # Bat — native
  programs.bat = {
    enable = true;
    config.theme = "catppuccin-mocha";
  };

  # Inputrc — symlink (complex readline config)
  home.file.".inputrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/core/shell/inputrc";

  # Dircolors — symlink
  home.file.".dircolors".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/core/shell/dircolors";
}
