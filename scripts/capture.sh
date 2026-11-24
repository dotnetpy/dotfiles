#!/usr/bin/env bash
# Compare this Mac with the repository and report what is missing from it.
#
# Prints packages and applications that are installed but not declared, and
# merges globally installed uv tools into uv-tools.txt. Never commits.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib.sh
source "$root/scripts/lib.sh"
cd "$root"

dump="$(mktemp)"
tools="$(mktemp)"
trap 'rm -f "$dump" "$tools"' EXIT

normalize() {
  grep -E '^(tap|brew|cask|mas) ' "$1" | sed -E 's/, id:.*//' | sort -u
}

info "Packages installed but not in the Brewfile"
brew bundle dump --file="$dump" --force
comm -13 <(normalize Brewfile) <(normalize "$dump") || true

info "Applications not managed by Homebrew or the App Store"
managed="$(brew info --cask --installed --json=v2 | grep -o '"[^"]*\.app"' | tr -d '"' | sort -u)"
for app in /Applications/*.app; do
  name="$(basename "$app")"
  [[ -L "$app" || -d "$app/Contents/_MASReceipt" ]] && continue
  grep -qxF "$name" <<<"$managed" && continue
  echo "$name"
done

info "Merging uv tools into uv-tools.txt"
{
  cat uv-tools.txt
  uv tool list 2>/dev/null | awk '/^[[:alnum:]].* v[0-9]/ { print $1 }'
} | sort -u >"$tools"
cp "$tools" uv-tools.txt

info "Review the changes with: git -C $root diff"
