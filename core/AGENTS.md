# core/ — Always-Installed Configs

Installed unconditionally on every platform by `core/.config.sh`. No bot selection.

## Sub-directories

| Path | Purpose |
|------|---------|
| `shell/` | Shell init (profile, shenv, inputrc, aliases, autoloads) |
| `term/` | Terminfo files for st + tmux 24-bit color |
| `fonts/` | Font files → `$XDG_DATA_HOME/fonts` |
| `banners/` | Image/banner files → `$XDG_CONFIG_HOME/banners` |
| `repos/walls/` | Wallpaper submodule → cloned by `sync-submodule` |
| `images/` | Wallpaper/profile images → `$XDG_PICTURES_DIR` |

## Shell Autoloads

`core/shell/autoloads/` is the entry point for shell rc scripts:
- `shell/` → bash/zsh/fish config fragments
- `cmds/` → scripts sourced into shell (linked from prog/*/auto/)
- Platform-specific: `linux`, `macos`, `windows`

Bootstrap order: `~/.profile` → `core/shell/shenv` → imports `xdgenv`, `dircolors`, `inputrc` + all autoloads.

## Other Files

- `mojis` → `$XDG_CONFIG_HOME/mojis`
- `prog-icons`, `diricons` → icon mappings
- `pylog` → `$XDG_CONFIG_HOME/pylog/default.yml`
- `lesskey` → `$XDG_CONFIG_HOME/less/lesskey.base`
- `mimeapps.list` → `$XDG_CONFIG_HOME/mimeapps.list`
- `curlrc` → `$XDG_CONFIG_HOME/.curlrc`
