{ config, pkgs, ... }:

let
  dotfiles = "/home/atan/dotfiles";
in
{
  # === HYBRID: symlink existing configs, migrate to native HM as needed ===

  # Neovim — SYMLINK existing init.vim (complex, actively edited)
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    # SYMLINK: keep your existing config, edit it directly
    extraConfig = builtins.readFile "${dotfiles}/prog/editors/nvim/init.vim";
    # NATIVE: remove extraConfig, use these when ready to own in Nix
    # plugins = with pkgs.vimPlugins; [
    #   catppuccin-nvim
    #   lualine-nvim
    #   nvim-web-devicons
    #   vim-fugitive
    #   gitsigns-nvim
    #   fzf-lua
    #   nvim-lspconfig
    #   mason-nvim
    #   mason-lspconfig-nvim
    #   nvim-cmp
    #   cmp-nvim-lsp
    #   luasnip
    #   (nvim-treesitter.withPlugins (p: [ p.bash p.lua p.nix p.python p.rust p.typescript ]))
    # ];
    # extraLuaConfig = ''
    #   require("catppuccin").setup({ flavour = "mocha" })
    #   vim.cmd.colorscheme("catppuccin")
    # '';
  };

  # Emacs — native (package management) + symlink existing config
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
    extraPackages = epkgs: with epkgs; [
      evil
      magit
      projectile
      company
      flycheck
      use-package
    ];
  };
  # SYMLINK: emacs config directory (if you have one in the dotfiles)
  # home.file.".emacs.d".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/prog/editors/emacs";

  # VSCode — native extensions + minimal settings
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      eamodio.gitlens
      ms-python.python
      rust-lang.rust-analyzer
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      catppuccin.catppuccin-vsc
    ];
    userSettings = {
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'JetBrains Mono', 'Fira Code', monospace";
      "editor.fontLigatures" = true;
      "editor.tabSize" = 2;
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "workbench.colorTheme" = "Catppuccin Mocha";
    };
  };
  # SYMLINK: for keybindings, tasks, etc. that aren't covered by HM
  # xdg.configFile."Code/User/keybindings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/prog/editors/vscode/keybindings.json";
}
