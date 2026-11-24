#!/usr/bin/env bash
# macOS preferences that differ from the system defaults.
#
# Set COMPUTER_NAME to also rename the machine (requires sudo).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib.sh
source "$root/scripts/lib.sh"

osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

if [[ -n "${COMPUTER_NAME:-}" ]]; then
  info "Setting computer name to $COMPUTER_NAME"
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$COMPUTER_NAME"
  sudo scutil --set LocalHostName "$COMPUTER_NAME"
fi

info "Applying macOS preferences"

# Appearance
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

killall SystemUIServer >/dev/null 2>&1 || true
