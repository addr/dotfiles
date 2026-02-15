# Dotfiles

Chezmoi-managed personal dotfiles for macOS (primary) and Ubuntu Linux. Currently undergoing modernization.

## Quick Reference

```sh
chezmoi apply                  # Apply all configs to $HOME
chezmoi diff                   # Preview changes before applying
chezmoi edit <file>            # Edit a managed file
chezmoi add <file>             # Add a new file to management
chezmoi init --apply           # First-time setup (runs install scripts)
./install.sh                   # Bootstrap from scratch
./test.sh                      # Docker smoke test (Ubuntu)
```

## Project Structure

```
├── .chezmoi.yaml.tmpl         # Template variables (name, email, github, etc.)
├── install.sh                 # Bootstrap entrypoint
├── test.sh                    # Docker-based Ubuntu smoke test
├── scripts/
│   ├── darwin/                # macOS run_once_after_* install scripts
│   └── linux/                 # Linux run_once_after_* install scripts
├── dot_config/
│   ├── macos/defaults.yaml    # macOS system preferences
│   └── nvim/init.vim          # Neovim config
├── dot_doom.d/                # Doom Emacs (placeholder)
├── dot_zshrc                  # Zsh config (Oh-My-Zsh + Starship)
├── dot_gitconfig.tmpl         # Git config (templated)
├── dot_tool-versions          # ASDF language versions
├── executable_dot_yabairc     # Yabai tiling WM
└── dot_skhdrc                 # SKHD hotkeys
```

## Configuration Flow

1. `install.sh` installs chezmoi and runs `chezmoi init --apply`
2. `.chezmoi.yaml.tmpl` prompts for template variables (skipped in CI/Codespaces)
3. `dot_*` files deploy to `$HOME` with the `dot_` prefix replaced by `.`
4. `.tmpl` files are rendered through chezmoi's template engine first
5. `scripts/{darwin,linux}/run_once_after_*` execute in numbered order (00→99)
6. `*.local` files (`~/.zshrc.local`, `~/.gitconfig.local`) provide per-machine overrides

## Template Variables

| Variable | Default | Used In |
|----------|---------|---------|
| `name` | Andy Rice | gitconfig |
| `email` | andydrice@gmail.com | gitconfig |
| `github_user` | addr | — |
| `asdf_version` | 0.9.0 | install scripts |
| `computer_name` | andyrice-computer-name | macOS naming |
| `hostname` | andyrice | macOS naming |

## Tool Stack

| Tool | Config | Notes |
|------|--------|-------|
| Zsh + Oh-My-Zsh | `dot_zshrc` | Starship prompt, vi-mode, many plugins |
| Git | `dot_gitconfig.tmpl` | VS Code diff/merge, diff-so-fancy pager |
| Neovim | `dot_config/nvim/init.vim` | Minimal config |
| Yabai | `executable_dot_yabairc` | BSP tiling, macOS only |
| SKHD | `dot_skhdrc` | Alt+hjkl nav, macOS only |
| ASDF | `dot_tool-versions`, `dot_asdfrc` | Node, Python, Go, Terraform, PHP |
| Doom Emacs | `dot_doom.d/` | Placeholder only |

## Important Constraints

- **Chezmoi owns `$HOME` dotfiles** — edit source files here, never `~/.zshrc` directly
- **`run_once_after_*` scripts are idempotent** — chezmoi tracks execution; they only run once per content hash
- **Template files require `chezmoi apply`** — direct edits to rendered files are overwritten
- **macOS scripts assume Homebrew** — it's installed in step 00 before anything else
- **ASDF version is pinned** (0.9.0) — update `.chezmoi.yaml.tmpl` to change it
- **Git config uses VS Code** as diff/merge tool — requires VS Code `code` CLI in PATH

## Git Workflow

- Single `master` branch
- No specific commit convention currently enforced
- CI runs Ubuntu smoke test via Docker on push
