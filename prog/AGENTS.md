# prog/ — Program Configuration Bots

Each subdirectory is a "bot" — an installable component. 66+ programs.

## Bot Conventions

```
prog/<name>/
├── .module.sh        # Installation directives (link, clean, package, import)
├── .config.sh        # Alternative filename (equivalent format)
├── cmds/             # Scripts linked to $XDG_BIN_DIR
├── auto/             # Auto-load scripts → $XDG_CONFIG_HOME/autoloads/cmds/
├── theme/            # Status bar theme modules
└── layouts/          # Window/tmux layouts
```

Config file search order: `.dotty.sh` → `.sh` → `dotty.sh` → `config.sh` → `.config.sh` → `.config` → `module.sh` → `.module.sh` → `.module`

## Key Groups

| Group | Contents |
|-------|---------|
| `desktop/` | Window managers (niri, wayland) |
| `editors/` | vim, nvim, emacs, vscode (some are submodules) |
| `langs/` | Language runtimes + LSP servers |
| `shells/` | bash, zsh, fish, pwsh |
| `terminal/` | alacritty, kitty, st, ghostty, hyper, yakuake... |
| `browsers/` | brave, firefox, librewolf, tor, zen |
| `media/` | mpd, mpv, lollypop, vlc |
| `media-server/` | transmission, qbittorrent + jellyfin |
| `network/` | network-manager, firewall, tailscale |
| `vpn/` | airvpn, mullvad, nordvpn |
| `games/` | steam, lutris, gog, gba |

## Loading

`prog/.config.sh` drives installation:
- Always: `git`, `shells/bash`, `info`, `editors`
- With `-b` (optional): `langs/*`, `desktop`, `browsers/*`, etc.
- `mail` only loads if both `mail.server` and `mail.client` bots active

All bots are listed in `setup/suggested` with presets (`default`, `develop`, `games`, `user`, `torrent`).
