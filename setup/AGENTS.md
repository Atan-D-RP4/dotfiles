# setup/ — Tooling & Infrastructure

## dotty — The Dotfile Manager

Core at `setup/dotty` (1437 lines). Bash-based. Sourced by `./manage`.

### Commands
```
./manage install=.         install everything
./manage install -b a,b    install specific bots
./manage list-bots         list discoverable bots
./manage list-conf         list imported configs
```

### Install Flags
- `-b BOTS` — comma-separated bot names
- `-a` — enable all optional `import -b` calls
- `-d` — dry-run (output install script to stdout)
- `-l trace|debug|info|warn|error` — log level
- `-e CMD` / `-o CMD` — skip / run-only directive type

## Linting

```
./setup/lint            # run linters on repo files
./setup/lint.docker     # run lint inside Arch Docker container
```

Runs: `shellcheck`, `pylint`, `rubocop`, `jsonlint`, `yamllint`, `mdl`. Broken symlinks also reported as errors.

Config files at `setup/conf/`:
- `shellcheckrc`, `pylintrc`, `rubocoprc`, `yamlrc`, `mdlstyle.rb`, `pycodestyle`, `pydocstyle`
- `lint.ignore` — files to exclude from linting

## Running lint in Docker

```sh
./setup/lint.docker                  # build + run
./setup/lint.docker ./setup/lint -v  # verbose
```

Docker image (`lint.Dockerfile`) is Arch-based with all linters pre-installed.

## Package Database

`setup/packages.csv` — maps program names to install specs:
```
# Program, Installed-Predicate, Manager:Package,...
tmux,which:tmux,apt:tmux,msys:tmux,yay:tmux-git
```
Predicates: `which:<binary>`, `stat:<path>`, `python-module:<name>`.

Used by the `packagex` directive in config files.

## Suggested Bots

`setup/suggested` — preset groups for interactive install selection:
- `default` — always-installed baseline
- `develop` + sub-presets (python, ruby, golang, node, c, shell)
- `games`, `user`, `torrent`

## Other

- `strap/` — Bootstrap install scripts per distro (currently only `arch/`)
- `clean` — Cleanup script
- `patch/` — Patches
- `docs/` — Additional docs (media-server, vps)
- `dotty-ls-imports`, `dotty-ls-modules` — Module discovery helpers
