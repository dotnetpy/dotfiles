#!/usr/bin/env bash
# Bootstrap a new Mac.
#
#   curl -fsSL https://raw.githubusercontent.com/dotnetpy/dotfiles/main/install.sh | bash
#
# Installs the Xcode Command Line Tools and Homebrew, clones this repository to
# ~/dotfiles (or DOTFILES_DIR) and runs `make install`.
set -euo pipefail

REPO_URL="https://github.com/dotnetpy/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

info() { printf '\033[34m==>\033[0m %s\n' "$*"; }
error() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

[[ "$(uname -s)" == "Darwin" ]] || error "this repository only supports macOS"

if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing the Xcode Command Line Tools"
  xcode-select --install || true
  info "Run this script again when the installation has finished"
  exit 0
fi

if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
  info "Installing Homebrew"
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

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

make -C "$DOTFILES_DIR" install
