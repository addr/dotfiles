export PATH=$HOME/.bin:$PATH:/usr/local/bin:/usr/local/sbin:/bin:/usr/sbin:/sbin:$HOME
export ZSH=$HOME/.oh-my-zsh

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
HIST_STAMPS="yyyy-mm-dd"

plugins=(asdf autojump alias-finder cp docker direnv history git gnu-utils vi-mode command-not-found zsh-autosuggestions poetry zsh-syntax-highlighting zsh-history-substring-search)

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

# hook into direnv
eval "$(direnv hook zsh)"

# load local zshrc if there is one
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

