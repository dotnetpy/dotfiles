#!/usr/bin/env bash
# Bootstrap a new Mac.
#
#   curl -fsSL https://raw.githubusercontent.com/dotnetpy/dotfiles/main/install.sh | bash
#
# Works on a Mac with nothing installed: installs the Xcode Command Line Tools
# (which provide git and make) and Homebrew, clones this repository to
# ~/dotfiles (or DOTFILES_DIR) and runs `make install`. Safe to run again.
set -euo pipefail

REPO_URL="https://github.com/dotnetpy/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
APP_MANAGEMENT_URL="x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles"

info() { printf '\033[34m==>\033[0m %s\n' "$*"; }
error() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

# Wait for Enter. When this script is piped from curl, stdin is the script
# itself, so read from the terminal instead.
pause() {
  if [[ -r /dev/tty ]]; then
    read -r -p "$1" </dev/tty || true
  fi
}

[[ "$(uname -s)" == "Darwin" ]] || error "this repository only supports macOS"

# 1. Xcode Command Line Tools: git, make and the compilers Homebrew needs.
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing the Xcode Command Line Tools: click Install in the dialog that opens"
  xcode-select --install >/dev/null 2>&1 || true
  info "Waiting for the installation to finish (press Ctrl-C to cancel)"
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
  info "Command Line Tools installed"
fi

# 2. Homebrew.
if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
  info "Installing Homebrew"
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. This repository (cloned over HTTPS, so no SSH key is needed).
script_dir=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [[ -n "$script_dir" && -f "$script_dir/Makefile" ]]; then
  DOTFILES_DIR="$script_dir"
elif [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  info "Cloning $REPO_URL into $DOTFILES_DIR"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# 4. App Management. Without it macOS blocks Homebrew from changing app
# bundles in /Applications, and casks such as 1password fail with
# "Operation not permitted". Only asked while something is still missing.
if ! brew bundle check --file="$DOTFILES_DIR/Brewfile" >/dev/null 2>&1; then
  info "Homebrew needs the App Management permission to install and update apps"
  info "Turn on your terminal app in Privacy & Security > App Management (opening it now)"
  info "If macOS asks to quit and reopen the terminal, do it and run this script again"
  open "$APP_MANAGEMENT_URL" >/dev/null 2>&1 || true
  pause "Press Enter to continue... "
fi

make -C "$DOTFILES_DIR" install
