# Dotfiles

Chezmoi-managed personal dotfiles for macOS (primary) and Ubuntu Linux.

## Quick Reference

```sh
chezmoi apply                  # Apply all configs to $HOME
chezmoi diff                   # Preview changes before applying
chezmoi edit <file>            # Edit a managed file
chezmoi add <file>             # Add a new file to management
chezmoi init --apply           # First-time setup (runs install scripts)
brew bundle --file=Brewfile    # Install all packages
./install.sh                   # Bootstrap from scratch
./test.sh                      # Docker smoke test (Ubuntu)
```

## Project Structure

```
.chezmoi.yaml.tmpl              # Template variables (name, email, github, etc.)
.chezmoiignore                  # Files to skip per OS
install.sh                      # Bootstrap entrypoint
test.sh                         # Docker-based Ubuntu smoke test

Brewfile                        # All packages — single file, OS conditionals

scripts/
  darwin/
    run_once_after_00-brew-bundle.sh.tmpl   # brew bundle
    run_once_after_01-macos-defaults.sh.tmpl # macOS system preferences
    run_once_after_99-macos-name.zsh.tmpl   # Set computer name/hostname
  linux/
    run_once_after_00-brew-bundle.sh.tmpl   # install brew + brew bundle

dot_config/
  aerospace/aerospace.toml      # AeroSpace tiling WM (macOS)
  ghostty/config                # Ghostty terminal
  nvim/                         # AstroNvim (lazy.nvim) config
  starship.toml                 # Starship prompt
  mise/config.toml              # mise global config (versions + env)
  atuin/config.toml             # Shell history sync

dot_zshrc.tmpl                  # Zsh config (Zinit-based)
dot_gitconfig.tmpl              # Git config (delta pager)
```

## Configuration Flow

1. `install.sh` installs Homebrew (if missing) and chezmoi
2. `chezmoi init --apply` prompts for template variables, deploys all dot_* files
3. `run_once_after_00-brew-bundle.sh` runs `brew bundle` to install all packages
4. `run_once_after_01-macos-defaults.sh` sets macOS system preferences (macOS only)
5. Zinit auto-installs plugins on first shell launch
6. mise installs language versions on first `mise install`
7. `*.local` files (`~/.zshrc.local`, `~/.gitconfig.local`) provide per-machine overrides

## Template Variables

| Variable | Default | Used In |
|----------|---------|---------|
| `name` | Andy Rice | gitconfig |
| `email` | andydrice@gmail.com | gitconfig |
| `github_user` | addr | — |
| `computer_name` | andyrice-computer-name | macOS naming |
| `hostname` | andyrice | macOS naming |

## Tool Stack

| Tool | Config | Notes |
|------|--------|-------|
| Zsh + Zinit | `dot_zshrc.tmpl` | Starship prompt, vi-mode, turbo-loaded plugins |
| Git + delta | `dot_gitconfig.tmpl` | Side-by-side diffs, zdiff3 merge conflicts |
| Neovim | `dot_config/nvim/` | AstroNvim v5 + lazy.nvim |
| AeroSpace | `dot_config/aerospace/` | i3-like tiling, alt+hjkl, macOS only |
| Ghostty | `dot_config/ghostty/` | Terminal emulator |
| mise | `dot_config/mise/` | Version manager + env vars (replaces asdf+direnv) |
| Atuin | `dot_config/atuin/` | Shell history with fuzzy search |
| Starship | `dot_config/starship.toml` | Cross-shell prompt |

## Important Constraints

- **Chezmoi owns `$HOME` dotfiles** — edit source files here, never `~/.zshrc` directly
- **`run_once_after_*` scripts are idempotent** — chezmoi tracks execution by content hash
- **Template files require `chezmoi apply`** — direct edits to rendered files are overwritten
- **Brewfile is the package source of truth** — add/remove packages there, not in install scripts
- **macOS scripts assume Homebrew** — it's installed in step 00 before anything else
- **Git config uses VS Code** as diff/merge tool — requires VS Code `code` CLI in PATH
- **AeroSpace replaces Yabai+SKHD** — no SIP disable needed, built-in hotkeys

## Git Workflow

- Single `master` branch
- CI runs Ubuntu smoke test via Docker on push
