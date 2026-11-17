# .github/ — CI Workflows

## Trigger: push to `master` only

| Workflow | File | Purpose |
|----------|------|---------|
| **lint** | `workflows/lint.yml` | Runs `./setup/lint.docker` (shellcheck, pylint, rubocop, jsonlint, yamllint, mdl in Arch container) |
| **docs** | `workflows/docs.yml` | Builds `README.org` → HTML via Emacs Org export. Currently disabled deploy step. |

## Key Details

- Lint workflow checks out submodules too
- `lint.Dockerfile` is Arch-based with all linters installed via pacman/npm/curl
- Docs workflow uses Emacs 27.1 (`purcell/setup-emacs` action), installs `htmlize` from MELPA
- No other CI checks (test, typecheck, deploy) exist
