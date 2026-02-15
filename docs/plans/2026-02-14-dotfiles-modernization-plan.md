# Dotfiles Modernization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modernize chezmoi-managed dotfiles — replace outdated tools, consolidate install scripts into a Brewfile, add configs for modern tools.

**Architecture:** Chezmoi remains the dotfile manager. A single Brewfile replaces per-tool install scripts. Old tools (Oh-My-Zsh, ASDF, Yabai/SKHD, diff-so-fancy) are swapped for modern equivalents (Zinit, mise, AeroSpace, delta). New tool configs (Ghostty, AeroSpace, Starship, mise, Atuin) are added under `dot_config/`.

**Tech Stack:** chezmoi, Homebrew/Brewfile, Zsh + Zinit, mise, AeroSpace, delta, Ghostty, Starship

**Design doc:** `docs/plans/2026-02-14-dotfiles-modernization-design.md`

---

### Task 1: Create the Brewfile

**Files:**
- Create: `Brewfile`

**Step 1: Write the Brewfile**

```ruby
# Brewfile

# --- Taps ---
tap "homebrew/bundle"
tap "nikitabobko/tap"

# --- Core CLI Tools ---
brew "bat"
brew "eza"
brew "fd"
brew "ripgrep"
brew "fzf"
brew "zoxide"
brew "git-delta"
brew "lazygit"
brew "atuin"
brew "starship"
brew "mise"
brew "jq"
brew "gh"
brew "tmux"
brew "neovim"
brew "pre-commit"
brew "git"

# --- macOS Only ---
if OS.mac?
  cask "aerospace"
  cask "ghostty"
  cask "karabiner-elements"
  cask "1password-cli"
  cask "hiddenbar"
  cask "maccy"
  cask "alt-tab"
  cask "orbstack"
  cask "obsidian"
  cask "cursor"
  cask "brave-browser"
  cask "slack"
  cask "spotify"
  cask "discord"
  cask "font-sf-mono-nerd-font"
end
```

**Step 2: Verify syntax**

Run: `brew bundle check --file=Brewfile` from the repo root.
Expected: reports missing packages (that's fine — confirms syntax is valid).

**Step 3: Commit**

```bash
git add Brewfile
git commit -m "Add Brewfile for declarative package management"
```

---

### Task 2: Replace install scripts

**Files:**
- Delete: `scripts/darwin/run_once_after_00-install-homebrew-macos.sh.tmpl`
- Delete: `scripts/darwin/run_once_after_01-install-rosetta-2-macos.sh.tmpl`
- Delete: `scripts/darwin/run_once_after_01-install-zsh-shell-macos.sh.tmpl`
- Delete: `scripts/darwin/run_once_after_10-install-packages-macos.sh.tmpl`
- Delete: `scripts/darwin/run_once_after_30-install-asdf-plugins-macos.sh.tmpl`
- Delete: `scripts/darwin/run_once_after_90-install-packages-apps-extra-macos.sh.tmpl`
- Delete: `scripts/linux/run_once_after_00-install-packages-linux.sh.tmpl`
- Delete: `scripts/linux/run_once_after_01-install-zsh-shell-linux.sh.tmpl`
- Delete: `scripts/linux/run_once_after_30-install-asdf-plugins-linux.sh.tmpl`
- Delete: `scripts/linux/ubuntu.yaml`
- Modify: `scripts/darwin/run_once_after_98-macos-preferences.sh.tmpl` → rename to `run_once_after_01-macos-defaults.sh.tmpl`
- Modify: `scripts/darwin/run_once_after_99-macos-name.zsh.tmpl` → keep as-is
- Create: `scripts/darwin/run_once_after_00-brew-bundle.sh.tmpl`
- Create: `scripts/linux/run_once_after_00-brew-bundle.sh.tmpl`

**Step 1: Create macOS brew bundle script**

File: `scripts/darwin/run_once_after_00-brew-bundle.sh.tmpl`
```bash
{{- if (eq .chezmoi.os "darwin") -}}
#!/bin/bash
set -euo pipefail

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Running brew bundle..."
brew bundle --file="{{ .chezmoi.sourceDir }}/Brewfile" --no-lock
{{ end -}}
```

**Step 2: Create Linux brew bundle script**

File: `scripts/linux/run_once_after_00-brew-bundle.sh.tmpl`
```bash
{{- if (eq .chezmoi.os "linux") -}}
#!/bin/bash
set -euo pipefail

# Install build dependencies (needed for Homebrew on Linux)
if command -v apt &>/dev/null; then
  sudo apt update -y
  sudo apt install -y build-essential curl git
fi

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "Running brew bundle..."
brew bundle --file="{{ .chezmoi.sourceDir }}/Brewfile" --no-lock
{{ end -}}
```

**Step 3: Rename macOS preferences script**

Rename `run_once_after_98-macos-preferences.sh.tmpl` to `run_once_after_01-macos-defaults.sh.tmpl` (content stays the same).

**Step 4: Delete old scripts**

Remove the files listed above (everything except the two new brew-bundle scripts, the macos-defaults script, and the macos-name script).

**Step 5: Commit**

```bash
git add scripts/
git commit -m "Replace per-tool install scripts with Brewfile-driven setup"
```

---

### Task 3: Write new shell config (dot_zshrc)

**Files:**
- Modify: `dot_zshrc` → replace contents entirely, rename to `dot_zshrc.tmpl`

**Step 1: Replace dot_zshrc with Zinit-based config**

Delete `dot_zshrc`, create `dot_zshrc.tmpl`:
```zsh
# --- Path ---
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# --- Zinit Bootstrap ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# --- Prompt ---
eval "$(starship init zsh)"

# --- Plugins (turbo-loaded, deferred) ---
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search

# --- Completions ---
zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# --- Tool Integrations ---
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"
eval "$(atuin init zsh)"

# --- History ---
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# --- Keybindings (vi-mode) ---
bindkey -v
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# --- Aliases ---
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias lt="eza --tree --icons"
alias cat="bat"
alias lg="lazygit"
alias cd="z"

# --- Local overrides ---
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
```

**Step 2: Commit**

```bash
git add dot_zshrc dot_zshrc.tmpl
git commit -m "Replace Oh-My-Zsh with Zinit-based shell config"
```

---

### Task 4: Update git config

**Files:**
- Modify: `dot_gitconfig.tmpl`

**Step 1: Replace dot_gitconfig.tmpl with delta-based config**

```ini
[user]
	name = {{ .name }}
	email = {{ .email }}

[core]
	autocrlf = input
	excludesfile = ~/.gitignore_global
	ignorecase = false
	editor = code --wait
	pager = delta

[interactive]
	diffFilter = delta --color-only

[delta]
	navigate = true
	side-by-side = true
	line-numbers = true

[diff]
	tool = vscode
	colorMoved = default

[difftool "vscode"]
	cmd = code --wait --diff $LOCAL $REMOTE

[merge]
	tool = vscode
	conflictstyle = zdiff3

[mergetool "vscode"]
	cmd = code --wait $MERGED

[pull]
	ff = only

[fetch]
	prune = true

[commit]
	template = ~/.gitmessage

[include]
	path = ~/.gitconfig.local
```

**Step 2: Commit**

```bash
git add dot_gitconfig.tmpl
git commit -m "Update git config: delta pager, zdiff3, drop manual colors"
```

---

### Task 5: Add AeroSpace config

**Files:**
- Create: `dot_config/aerospace/aerospace.toml`

**Step 1: Write AeroSpace config**

Create `dot_config/aerospace/aerospace.toml` with the full config from the design doc (Section 5). This includes:
- `start-at-login = true`
- 10px gaps
- `alt+hjkl` focus, `alt+shift+hjkl` move
- `alt+1-9` workspaces, `alt+shift+1-9` move-to-workspace
- Layout toggles, fullscreen, reload

**Step 2: Commit**

```bash
git add dot_config/aerospace/
git commit -m "Add AeroSpace tiling WM config (replaces yabai+skhd)"
```

---

### Task 6: Add Ghostty, Starship, mise, Atuin configs

**Files:**
- Create: `dot_config/ghostty/config`
- Create: `dot_config/starship.toml`
- Create: `dot_config/mise/config.toml`
- Create: `dot_config/atuin/config.toml`

**Step 1: Write Ghostty config**

File: `dot_config/ghostty/config`
```
font-family = SF Mono
font-size = 14
theme = catppuccin-mocha
window-padding-x = 8
window-padding-y = 8
window-decoration = true
macos-titlebar-style = tabs
copy-on-select = clipboard
```

**Step 2: Write Starship config**

File: `dot_config/starship.toml`
```toml
[character]
success_symbol = "[›](bold green)"
error_symbol = "[›](bold red)"

[directory]
truncation_length = 3

[git_branch]
symbol = " "

[git_status]
disabled = false

[cmd_duration]
min_time = 2000
show_milliseconds = false
```

**Step 3: Write mise config**

File: `dot_config/mise/config.toml`
```toml
[tools]
node = "lts"
python = "3.13"
go = "latest"

[settings]
experimental = true
```

**Step 4: Write Atuin config**

File: `dot_config/atuin/config.toml`
```toml
dialect = "us"
style = "compact"
inline_height = 20
show_preview = true
filter_mode = "global"
search_mode = "fuzzy"
```

**Step 5: Commit**

```bash
git add dot_config/ghostty/ dot_config/starship.toml dot_config/mise/ dot_config/atuin/
git commit -m "Add configs for Ghostty, Starship, mise, and Atuin"
```

---

### Task 7: Add AstroNvim config

**Files:**
- Delete: `dot_config/nvim/init.vim`
- Delete: `dot_config/nvim/.keep`
- Create: `dot_config/nvim/` — copy from `~/.config/nvim/`

**Step 1: Remove old nvim config**

```bash
rm dot_config/nvim/init.vim dot_config/nvim/.keep
```

**Step 2: Copy AstroNvim config into dotfiles**

```bash
cp ~/.config/nvim/init.lua dot_config/nvim/
cp ~/.config/nvim/.stylua.toml dot_config/nvim/
cp -r ~/.config/nvim/lua/ dot_config/nvim/lua/
```

Do NOT copy `lazy-lock.json` (machine-specific), `.luarc.json`, `.neoconf.json`, or `neovim.yml`.

**Step 3: Commit**

```bash
git add dot_config/nvim/
git commit -m "Replace init.vim with AstroNvim lua config"
```

---

### Task 8: Delete obsolete files

**Files:**
- Delete: `executable_dot_yabairc`
- Delete: `dot_skhdrc`
- Delete: `dot_doom.d/` (entire directory)
- Delete: `dot_asdfrc`
- Delete: `dot_config/nvim/init.vim` (if not already removed in Task 7)

**Step 1: Remove files**

```bash
git rm executable_dot_yabairc dot_skhdrc dot_asdfrc
git rm -r dot_doom.d/
```

**Step 2: Commit**

```bash
git commit -m "Remove yabai, skhd, doom emacs, asdf configs"
```

---

### Task 9: Update chezmoi template and ignore

**Files:**
- Modify: `.chezmoi.yaml.tmpl` — remove `asdf_version`
- Modify: `.chezmoiignore` — update for new file layout

**Step 1: Update .chezmoi.yaml.tmpl**

Remove the `asdf_version` variable and its `promptString` line. Keep all other variables.

**Step 2: Update .chezmoiignore**

```
install.sh
test.sh
Brewfile
docs/
CLAUDE.md
.github/
README.md
```

This ensures chezmoi doesn't try to deploy repo-level files to `$HOME`.

**Step 3: Commit**

```bash
git add .chezmoi.yaml.tmpl .chezmoiignore
git commit -m "Update chezmoi template vars and ignore list"
```

---

### Task 10: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Rewrite CLAUDE.md to reflect new project state**

Update the project structure, tool stack, commands, template variables, and constraints sections to match the modernized setup. Remove references to Oh-My-Zsh, ASDF, Yabai, SKHD, Doom Emacs, diff-so-fancy.

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "Update CLAUDE.md for modernized dotfiles"
```

---

### Task 11: Verify on this machine

**Step 1: Run chezmoi diff**

```bash
chezmoi diff
```

Review the diff to confirm all new files would be deployed correctly and no unexpected changes.

**Step 2: Dry-run brew bundle**

```bash
brew bundle check --file=Brewfile
```

Confirm it identifies the packages not yet installed (bat, eza, zoxide, delta, lazygit, atuin, mise, aerospace).

**Step 3: Apply (when ready)**

```bash
chezmoi apply
brew bundle --file="$(chezmoi source-path)/Brewfile" --no-lock
```

This step is manual — only run when Andy is ready to switch.
