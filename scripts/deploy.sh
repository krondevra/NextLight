#!/usr/bin/env bash
# Copies flake.nix + modules/ into /etc/nixos and rebuilds the running
# system. Run this after `git pull` to apply local changes without
# retyping install.sh's copy step by hand every time.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

echo "==> Copying flake.nix + modules/ to /etc/nixos..."
sudo cp "$REPO_DIR/flake.nix" /etc/nixos/flake.nix
sudo cp -r "$REPO_DIR/modules" /etc/nixos/

echo "==> nixos-rebuild switch..."
sudo nixos-rebuild switch --flake /etc/nixos#nixos
