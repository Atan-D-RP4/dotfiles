# bin/ — Scripts Directory

All scripts here are symlinked to `$XDG_BIN_DIR` by `bin/.config.sh`.

~60 scripts: shell, python, ruby. Each should have a usage header.

## Key Utility Scripts (referenced elsewhere)

| Script | Purpose |
|--------|---------|
| `ls-platform` | Outputs `linux`, `macos`, `windows`, `freebsd` |
| `ls-distro` | Outputs distro name (arch, ubuntu) from `/etc/os-release` |
| `project-files` | Lists tracked repo files (used by lint) |
| `broken-links` | Finds broken symlinks (used by lint) |
| `python3-dotfiles-venv` | Python venv for dotfile scripts |
| `notifier` | Desktop notifications |

## Sub-directories

- `theme/` — Sidebar/widget status modules. Installed with `theme-` prefix via `link -p theme-`. Depends on `bin/lib/langs/python` module.
- `lib/python/` — Shared Python lib linked to `$XDG_DEV_HOME/.modules/python/mohkale`
