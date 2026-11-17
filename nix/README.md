# NixOS Configuration

NixOS + Home Manager with **hybrid dotfile management**: symlink existing configs from the dotfiles repo, gradually migrate to native HM options as configs evolve for NixOS.

## Architecture

```
nix/
├── flake.nix                         # Flake: standalone HM + NixOS integration
├── hosts/
│   └── atan/
│       ├── configuration.nix         # NixOS system config
│       ├── hardware-configuration.nix # Hardware (generated)
│       └── home.nix                  # User env: imports modules, core packages
└── modules/
    ├── nixos/
    │   ├── base.nix                  # System packages, locale, nix settings
    │   └── desktop.nix               # Hyprland, audio, fonts, display manager
    └── home/
        ├── shell.nix                 # Bash/Zsh/Fish (symlink existing, migrate to native)
        ├── editors.nix               # Neovim/Emacs/VSCode (hybrid)
        ├── terminals.nix             # Alacritty/Kitty/Ghostty (hybrid)
        ├── dev.nix                   # Git/Tmux/Docker/Languages (hybrid)
        └── dotfiles.nix              # Core files, XDG, mimeapps (symlink)
```

## The Hybrid Approach

Each module supports **two modes** per config:

### Mode 1: SYMLINK (start here)
Links your existing config file from the dotfiles repo. Edit it directly — no rebuild needed.

```nix
# dev.nix
programs.git = {
  enable = true;
  extraConfig = builtins.fromTOML (builtins.readFile "${dotfiles}/prog/git/gitconfig");
};
```

### Mode 2: NATIVE HM (migrate here)
Own the config in Nix. Rebuild-aware, declarative, type-safe.

```nix
# dev.nix
programs.git = {
  enable = true;
  userName = "Atan-D-RP4";
  userEmail = "atan@example.com";
  extraConfig = { pull.rebase = true; };
  aliases = { s = "status"; };
};
```

### Transition per-config
- Start with symlink for configs you actively edit
- When a config stabilizes for NixOS, migrate to native HM
- Some configs (e.g., tmux status bar) may stay symlinked forever

## Quick Start

### Option 1: Standalone HM (no NixOS needed)

Test on any Linux system with Nix installed:

```bash
# Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Build and activate
cd nix
home-manager switch --flake .#atan
```

### Option 2: Full NixOS

Boot from NixOS ISO, then:

```bash
# Partition and mount disks
mkfs.ext4 -L nixos /dev/sda1
mkfs.fat -F 32 -n boot /dev/sda2
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# Clone and switch
git clone https://github.com/Atan-D-RP4/dotfiles.git /mnt/etc/nixos
cd /mnt/etc/nixos/nix
sudo nixos-rebuild switch --flake .#atan
```

### Update

```bash
# Rebuild system
sudo nixos-rebuild switch --flake .#atan

# Or standalone HM
home-manager switch --flake .#atan

# Update flake inputs
nix flake update
```

## What Gets Symlinked vs Native

| Config | Approach | Why |
|--------|----------|-----|
| `prog/git/gitconfig` | SYMLINK | 202 lines, complex, actively edited |
| `prog/tmux/tmuxrc` | SYMLINK | 440 lines, complex status bar |
| `prog/editors/nvim/init.vim` | SYMLINK | Complex, actively edited |
| `prog/shells/bash/bashrc` | SYMLINK | Shell-specific, complex |
| `prog/shells/zsh/zshrc` | SYMLINK | Shell-specific, complex |
| `prog/terminal/alacritty/alacritty.toml` | SYMLINK | Theme, actively edited |
| `prog/terminal/kitty/kitty.conf` | SYMLINK | Theme, actively edited |
| `core/shell/shenv` | SYMLINK | Shared shell env, complex |
| `core/shell/inputrc` | SYMLINK | Readline config |
| Shell aliases | NATIVE | Simple, declarative |
| Session variables | NATIVE | Clean env management |
| FZF/Direnv/Zoxide/Eza | NATIVE | Simple, well-supported by HM |
| Starship prompt | NATIVE | No existing config |
| LazyGit | NATIVE | Simple settings |
| Delta (git diff) | NATIVE | Simple settings |
| Ripgrep/FD ignore | NATIVE | Simple text config |

## Adding a New Host

1. Create `hosts/<hostname>/configuration.nix`
2. Create `hosts/<hostname>/hardware-configuration.nix`
3. Create `hosts/<hostname>/home.nix`
4. Add to `flake.nix`:
   ```nix
   nixosConfigurations.<hostname> = mkHost "<hostname>";
   ```

## Rollback

```bash
# List generations
nix-env --list-generations

# Switch to previous
sudo nixos-rebuild switch --switch-generation <number>

# Or boot menu
# Select previous generation at boot
```

## Troubleshooting

```bash
# Check for errors
nix flake check

# Verbose build
sudo nixos-rebuild switch --flake .#atan --verbose

# Garbage collect
sudo nix-collect-garbage -d
```
