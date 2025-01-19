HISTFILE="$HOME/.histfile"             # Save 100000 lines of history
HISTSIZE=100000
SAVEHIST=100000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.

source "$HOME/.config/fzf/key-bindings.zsh"
source "$HOME/.config/fzf/completion.zsh"
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source <(fzf --zsh)

alias reload="source ~/.zshrc"
alias history="history 0"
alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -la --icons --octal-permissions --group-directories-first'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'
alias cat='bat --style=plain'
alias cd='z'
alias k='kubectl'
alias kx='kubectx'
alias gsa='git-status-all'
alias sehs='search-event-hub-case-sensitive'
alias sehi='search-event-hub-case-insensitive'
alias hist='history | fzf'

export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
export GOPATH="$HOME/go"


# Source work-specific configurations if the directory exists
if [[ -d "$HOME/.work/zshrc" ]]; then
  for file in $HOME/.work/zshrc/*; do
    if [[ -f "$file" && -r "$file" ]]; then
      source "$file"   # or . "$file"
    fi
  done
fi


eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

