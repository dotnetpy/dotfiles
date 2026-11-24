# Interactive shell.
# Secrets and machine-specific settings go in ~/.zshrc.local (not tracked).

export EDITOR="nvim"
export VISUAL="code --wait"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# Completion
if command -v brew >/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# Python (uv only)
if command -v uv >/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
fi

pynew() {
  if [[ -z "$1" ]]; then
    echo "usage: pynew <name>" >&2
    return 1
  fi
  uv init "$1" && cd "$1" && uv add --dev ruff ty pytest
}

# Aliases
alias vim="nvim"
alias ll="ls -lAhG"
alias py="uv run python"

# Prompt
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
