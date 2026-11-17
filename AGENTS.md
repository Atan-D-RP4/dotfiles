# AGENTS.md — Dotfiles Repository

## Quick Start

```sh
./manage install=.                        # full install
./manage install -b prog1,prog2           # selective bots
./manage list-bots                        # list installable components
./manage list-conf                        # list config files
```

## Dotfile Manager: dotty

This repo uses a custom bash-based dotfile manager at `setup/dotty` (1437 lines). The `./manage` script sources XDG vars then delegates to `setup/dotty`.

Install flags:
- `-b BOTS` — comma-separated bot list
- `-a` — install all optional bots
- `-d` — dry-run (output commands as script)
- `-l LEVEL` — log level: trace, debug, info, warn, error
- `-e CMD` / `-o CMD` — skip / run-only directive type

## Repo Layout

| Path | Purpose |
|------|---------|
| `core/` | Installed unconditionally on every platform |
| `bin/` | Scripts linked into `$XDG_BIN_DIR` |
| `prog/<name>/` | One directory per program (a "bot") |
| `dist/` | Distro-specific configs (arch, ubuntu, linux, windows) |
| `setup/` | dotty, lint, docker, strap, config templates |

Program configurations under `prog/` follow these conventions:
- `.module.sh` — installation directives (link, clean, package, import)
- `.config.sh` — same format, alternative filename
- `cmds/` — scripts linked to `$XDG_BIN_DIR`
- `auto/` — auto-load scripts linked to `$XDG_CONFIG_HOME/autoloads/cmds/`

Dotty searches for config files in this order: `.dotty.sh` → `.sh` → `dotty.sh` → `config.sh` → `.config.sh` → `.config` → `module.sh` → `.module.sh` → `.module`

## Core Directives (used in .module.sh / .config.sh)

- `link [-f] [-r] SRC:DEST ...` — create symlinks. `-f` overwrites, `-r` relinks existing symlinks
- `link-to DEST GLOB...` — link files matching glob into DEST
- `clean [-r] PATH...` — remove broken symlinks under PATH
- `makedir PATH...` — create directories
- `package <pm> PKGS...` — install with specific package manager
- `packages apt:pkg1,pkg2 pacman:pkg3` — try managers in order
- `packagex PKG...` — lookup in `setup/packages.csv` for install specs
- `import [-b] [-f] PATH...` — source another config. `-b` skips if bot not selected. `-f` auto-finds `.module.sh`
- `sync-submodule PATH` — init git submodule if not cloned
- `run-cmd ...` / `run-cmds` — execute shell commands
- `bots [-a] NAME...` — check if a bot is selected

## Platform Predicates

```sh
is-linux     is-windows     is-darwin     is-freebsd     is-unix
```

Used in config files for platform-conditional logic. Detection via `bin/ls-platform` and `bin/ls-distro`.

## Package Managers

Supported: `apt`, `pacman`, `yay`, `paru`, `choco`, `msys`, `pip`, `pipx`, `go`, `npm`, `yarn`, `gem`, `cygwin`

Multi-manager fallback pattern:
```sh
packages pacman:tmux yay:tmux-git choco:tmux
```

## Environment Variables

- `DOTFILES` — repo root (set by `./manage`)
- `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_STATE_HOME`, `XDG_BIN_DIR` — standard XDG
- `XDG_DEV_HOME`, `XDG_TEMP_DIR`, `XDG_GAMES_DIR` — custom extensions
- `$HOME/.env.local` — loaded if present

## Git Submodules

Listed in `.gitmodules`:
- `prog/editors/emacs` → `mohkale/emacs`
- `prog/editors/nvim/nvim_conf` → `Atan-D-RP4/nuanced.nvim`
- `prog/editors/vim` → `Atan-D-RP4/nuanced.vim`
- `core/repos/walls`, `prog/pass/store`, `prog/sxiv/src`, `prog/terminal/st/src`, and several theme submodules.

After cloning: `git submodule update --init --recursive`

## Linting

```sh
./setup/lint                    # run all linters on project files
./setup/lint.docker             # run lint inside Docker (Arch-based)
```

Lints: shellcheck, pylint, rubocop, jsonlint, yamllint, mdl. Dockerfile installs all tools in an Arch container.

CI runs lint on master push only (`.github/workflows/lint.yml`). Also run docs build via Emacs Org export (`.github/workflows/docs.yml`).

## Editor Config

`.dir-locals.el` sets `sh-shell` to `bash` for all `config.sh`/`module.sh` files.

## OpenCode Config

Located at `prog/opencode/opencode.jsonc`. Instructions reference `AGENTS.md`, `CONTRIBUTING.md`, and `docs/principles/*` (not yet created). This file itself is installed as a bot via `prog/opencode/.module.sh`, which symlinks opencode config, agent prompts, tools, and commands to `$XDG_CONFIG_HOME/opencode/`.
