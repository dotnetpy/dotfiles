#!/usr/bin/env bash
# Symlink every file under home/ to the same path under $HOME.
#
# Usage: scripts/link.sh [--dry-run | --check]
#
# Existing files are moved to ~/.dotfiles-backup/<timestamp>/ before linking.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib.sh
source "$root/scripts/lib.sh"

mode="link"
case "${1:-}" in
  "") ;;
  --dry-run) mode="dry-run" ;;
  --check) mode="check" ;;
  *) error "unknown option: $1" ;;
esac

backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
status=0

while IFS= read -r -d '' src; do
  rel="${src#"$root/home/"}"
  dst="$HOME/$rel"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    continue
  fi

  case "$mode" in
    check)
      warn "not linked: ~/$rel"
      status=1
      ;;
    dry-run)
      info "would link ~/$rel"
      ;;
    link)
      if [[ -e "$dst" || -L "$dst" ]]; then
        mkdir -p "$(dirname "$backup_dir/$rel")"
        mv "$dst" "$backup_dir/$rel"
        info "backed up ~/$rel"
      fi
      mkdir -p "$(dirname "$dst")"
      ln -s "$src" "$dst"
      info "linked ~/$rel"
      ;;
  esac
done < <(find "$root/home" -type f -print0 | sort -z)

if [[ "$mode" == "check" && "$status" -eq 0 ]]; then
  info "all links are in place"
fi

exit "$status"
