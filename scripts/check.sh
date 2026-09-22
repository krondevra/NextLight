#!/usr/bin/env bash
# Local equivalent of the CI "check" workflow: renders a fake disko-config.nix
# + boot.nix (same templating install.sh uses) and runs `nix flake check`
# against them, then restores the repo to its original state.
#
# Usage: ./scripts/check.sh [uefi|bios]
# With no argument, boot mode is auto-detected the same way install.sh does.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_DIR"

BOOT_MODE="${1:-}"
if [[ -z "$BOOT_MODE" ]]; then
  if [[ -d /sys/firmware/efi ]]; then
    BOOT_MODE="uefi"
  else
    BOOT_MODE="bios"
  fi
fi

if [[ "$BOOT_MODE" != "uefi" && "$BOOT_MODE" != "bios" ]]; then
  echo "Usage: $0 [uefi|bios]" >&2
  exit 1
fi

cleanup() {
  git reset -q -- boot.nix disko-config.nix 2>/dev/null || true
  git checkout -- disko-config.nix 2>/dev/null || true
  rm -f boot.nix
}
trap cleanup EXIT

echo "==> Rendering fake disko-config.nix + boot.nix ($BOOT_MODE)..."
tmp="$(mktemp -d)"
"$SCRIPT_DIR/render-boot-config.sh" "$REPO_DIR" /dev/vda "$BOOT_MODE" "$tmp"
cp "$tmp/disko-config.nix" ./disko-config.nix
cp "$tmp/boot.nix" ./boot.nix
git add boot.nix disko-config.nix

echo "==> nix flake check --no-build ($BOOT_MODE)..."
nix flake check --no-build

echo "==> OK: flake evaluates cleanly for $BOOT_MODE."
