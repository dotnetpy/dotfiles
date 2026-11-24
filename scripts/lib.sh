# shellcheck shell=bash
# Shared helpers. Source this file; do not execute it.

info() { printf '\033[34m==>\033[0m %s\n' "$*"; }

warn() { printf 'warning: %s\n' "$*" >&2; }

error() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}
