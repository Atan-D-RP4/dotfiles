{ config, pkgs, ... }:

let
  dotfiles = "/home/atan/dotfiles";
in
{
  # === HYBRID: symlink existing configs, migrate to native HM as needed ===

  # Git — SYMLINK existing gitconfig (202 lines, complex)
  programs.git = {
    enable = true;
    # SYMLINK: keep your existing config
    extraConfig = builtins.fromTOML (builtins.readFile "${dotfiles}/prog/git/gitconfig");
    # NATIVE: uncomment when ready to own in Nix
    # userName = "Atan-D-RP4";
    # userEmail = "atan@example.com";
    # extraConfig = {
    #   init.defaultBranch = "main";
    #   pull.rebase = true;
    #   push.autoSetupRemote = true;
    #   core.editor = "nvim";
    # };
    # aliases = {
    #   s = "status";
    #   l = "log --oneline --graph --decorate";
    # };
    # ignores = [ ".DS_Store" "*.swp" "result" ];
  };

  # Git — delta for diff viewing
  programs.git = {
    extraConfig = {
      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;
          navigate = true;
          syntax-theme = "Catppuccin Mocha";
        };
      };
    };
  };

  # LazyGit — native
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ "#89b4fa" "bold" ];
          inactiveBorderColor = [ "#a6adc8" ];
          searchingActiveBorderColor = [ "#f9e2af" "bold" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitFgColor = [ "#89b4fa" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
        };
        showIcons = true;
      };
    };
  };

  # Tmux — SYMLINK existing tmuxrc (440 lines, complex)
  programs.tmux = {
    enable = true;
    # SYMLINK: keep your existing config
    extraConfig = builtins.readFile "${dotfiles}/prog/tmux/tmuxrc";
    # NATIVE: uncomment when ready
    # keyMode = "vi";
    # mouse = true;
    # terminal = "tmux-256color";
    # historyLimit = 50000;
    # plugins = with pkgs.tmuxPlugins; [ sensible vim-tmux-navigator tmux-fzf ];
  };

  # Development packages
  home.packages = with pkgs; [
    # Languages
    python3
    nodejs
    go
    cargo
    rustc
    rust-analyzer

    # Build tools
    gcc
    gnumake
    cmake
    pkg-config

    # Package managers
    npm
    yarn
    pip
    poetry

    # Version control
    lazygit
    delta

    # Containers
    docker
    docker-compose

    # Databases
    sqlite
    postgresql

    # API tools
    curl
    httpie
    jq
    yq-go

    # Documentation
    pandoc
    typst

    # Misc
    shellcheck
    shfmt
    nodePackages.prettier
    stylua
  ];

  # Docker Compose completion
  programs.bash.initExtra = ''
    source <(docker completion bash)
  '';
  programs.zsh.initExtra = ''
    source <(docker completion zsh)
  '';

  # Environment variables for development
  home.sessionVariables = {
    GOPATH = "$HOME/.local/share/go";
    GOBIN = "$HOME/.local/bin";
    CARGO_HOME = "$HOME/.local/share/cargo";
    RUSTUP_HOME = "$HOME/.local/share/rustup";
    NODE_REPL_HISTORY = "$HOME/.local/state/node/repl_history";
    PYTHONSTARTUP = "$HOME/.pythonstartup";
  };

  # Create directories for development
  home.activation.createDevDirs = ''
    mkdir -p $HOME/.local/share/go
    mkdir -p $HOME/.local/share/cargo
    mkdir -p $HOME/.local/share/rustup
    mkdir -p $HOME/.local/state/node
  '';
}
