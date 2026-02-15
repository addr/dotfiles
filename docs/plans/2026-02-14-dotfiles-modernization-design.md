# Dotfiles Modernization Design

**Date:** 2026-02-14
**Approach:** Chezmoi + Brewfile-Driven

## Summary

Full modernization of chezmoi-managed dotfiles for macOS (primary) and Linux dev machines. A single Brewfile becomes the source of truth for all packages. Install scripts are reduced to `brew bundle` + macOS defaults. Every major tool is replaced with its modern equivalent.

## Tool Replacements

| Old | New | Reason |
|-----|-----|--------|
| Oh-My-Zsh | Zinit | Turbo mode, 80% faster startup, no framework overhead |
| ASDF (0.9.0) | mise | Rust-based, faster, built-in env vars (replaces direnv too) |
| Yabai + SKHD + Amethyst | AeroSpace | Single tool, no SIP disable, TOML config, built-in hotkeys |
| diff-so-fancy | delta | Syntax highlighting, side-by-side, line numbers |
| autojump | zoxide | Smarter directory learning, faster |
| Neovim init.vim | AstroNvim (lazy.nvim) | Already started on this machine, lua-based |
| Doom Emacs placeholder | Removed | Never used |
| direnv | mise | mise handles per-directory env vars natively |

## New Tools Added

| Tool | Purpose |
|------|---------|
| bat | cat replacement with syntax highlighting |
| eza | ls replacement with git status, icons |
| lazygit | Git TUI client |
| atuin | Shell history with search and optional sync |
| Ghostty | Terminal emulator (already installed) |

## Project Structure

```
.chezmoi.yaml.tmpl              # Template variables (name, email, github, etc.)
.chezmoiignore                  # Files to skip per OS
install.sh                      # Bootstrap: install chezmoi, brew, run init
test.sh                         # Docker smoke test (Ubuntu)

Brewfile                        # All packages — single file, OS conditionals

scripts/
  darwin/
    run_once_after_00-brew-bundle.sh     # brew bundle
    run_once_after_01-macos-defaults.sh  # macOS system preferences
  linux/
    run_once_after_00-brew-bundle.sh     # install brew + brew bundle

dot_config/
  ghostty/config                # Ghostty terminal
  nvim/                         # AstroNvim config
  aerospace/aerospace.toml      # AeroSpace tiling WM
  starship.toml                 # Starship prompt
  mise/config.toml              # mise global config
  atuin/config.toml             # Shell history

dot_zshrc.tmpl                  # Zsh config (Zinit-based)
dot_gitconfig.tmpl              # Git config (delta pager)
dot_tool-versions               # Kept for mise backwards compat

CLAUDE.md                       # AI agent instructions
.github/workflows/main.yml     # CI smoke test
```

## Brewfile

Single file with `OS.mac?` / `OS.linux?` conditionals.

**Cross-platform (CLI):** bat, eza, fd, ripgrep, fzf, zoxide, git-delta, lazygit, atuin, starship, mise, jq, gh, tmux, neovim, pre-commit

**macOS only (casks):** aerospace, ghostty, karabiner-elements, 1password-cli, hiddenbar, maccy, alt-tab, orbstack, obsidian, cursor, brave-browser, slack, spotify, discord, font-sf-mono-nerd-font

## Shell Config (dot_zshrc.tmpl)

Zinit-based. Key design decisions:
- **3 core plugins:** zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search
- **Tool inits via eval:** mise, zoxide, fzf, atuin, starship
- **vi-mode:** native `bindkey -v`, no plugin needed
- **Aliases:** ls=eza, cat=bat, cd=z, lg=lazygit
- **Local overrides:** `~/.zshrc.local` sourced at end

## Git Config (dot_gitconfig.tmpl)

- **Pager:** delta with side-by-side, line numbers, navigate mode
- **Merge conflictstyle:** zdiff3 (shows base in conflicts)
- **colorMoved:** enabled
- **Editor/difftool/mergetool:** VS Code
- **Local overrides:** `~/.gitconfig.local`
- **Removed:** all manual `[color]` sections (delta handles this)

## AeroSpace Config

- **Modifier:** alt (matches old skhd muscle memory)
- **Focus:** alt+hjkl
- **Move:** alt+shift+hjkl
- **Workspaces:** alt+1-9, move with alt+shift+1-9
- **Layout:** alt+slash (tiles), alt+comma (accordion), alt+f (fullscreen)
- 10px gaps, auto orientation, start at login

## Remaining Configs

- **Ghostty:** SF Mono 14, catppuccin-mocha, tab-style titlebar
- **Starship:** minimal — custom character symbol, truncated dirs, git info
- **mise:** node lts, python 3.13, go latest
- **Atuin:** compact style, fuzzy search, inline preview

## Template Variables

| Variable | Default | Used In |
|----------|---------|---------|
| `name` | Andy Rice | gitconfig |
| `email` | andydrice@gmail.com | gitconfig |
| `github_user` | addr | — |
| `computer_name` | andyrice-computer-name | macOS defaults |
| `hostname` | andyrice | macOS defaults |

`asdf_version` dropped — no longer needed.

## Files Deleted

- `dot_doom.d/` — placeholder, never used
- `dot_config/nvim/init.vim` — replaced by AstroNvim lua config
- `executable_dot_yabairc` — replaced by AeroSpace
- `dot_skhdrc` — replaced by AeroSpace
- `dot_asdfrc` — replaced by mise
- Old per-tool install scripts (replaced by Brewfile)

## Configuration Flow

1. `install.sh` installs Homebrew (if missing) and chezmoi
2. `chezmoi init --apply` prompts for template variables, deploys all dot_* files
3. `run_once_after_00-brew-bundle.sh` runs `brew bundle` to install all packages
4. `run_once_after_01-macos-defaults.sh` sets macOS system preferences (macOS only)
5. Zinit auto-installs plugins on first shell launch
6. mise installs language versions on first `mise install`
7. `*.local` files provide per-machine overrides
