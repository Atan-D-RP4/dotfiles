# dist/ — Distribution-Specific Configs

Conditionally loaded by `config.sh` based on `bin/ls-distro` output.

## Sub-directories

| Path | When Loaded |
|------|-------------|
| `arch/` | `ls-distro` returns "arch" |
| `ubuntu/` | `ls-distro` returns "ubuntu" |
| `linux/` | `is-linux` predicate |
| `windows/` | `is-windows` predicate |

## Usage Pattern

```sh
# in config.sh:
[ -e "$dist/arch"   ] && import dist/arch
[ -e "$dist/ubuntu" ] && import dist/ubuntu
is-windows            && import dist/windows
is-linux              && import dist/linux
```

Dist configs set up platform prerequisites (package managers, base packages, XDG paths) before program configs are imported. `dist/linux` always runs on any Linux, `dist/arch` and `dist/ubuntu` only run on their respective distros.
