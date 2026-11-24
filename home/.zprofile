# Login shell: environment and PATH.

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/Brewfile"
export PATH="$HOME/.local/bin:$PATH"
