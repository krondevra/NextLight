#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -d /sys/firmware/efi ]]; then
  BOOT_MODE="uefi"
else
  BOOT_MODE="bios"
fi

echo "[0] Boot mode detected: $BOOT_MODE"
echo "[1] Available disks:"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
echo

read -rp "Enter target disk (example: vda, /dev/vda, sda, /dev/sda, nvme0n1): " DISK

if [[ "$DISK" != /dev/* ]]; then
  DISK="/dev/$DISK"
fi

if [[ ! -b "$DISK" ]]; then
  echo "Error: disk $DISK does not exist."
  exit 1
fi

echo
echo "Script dir: $SCRIPT_DIR"
echo "Target disk: $DISK"
echo "Boot mode: $BOOT_MODE"
read -rp "ALL DATA ON $DISK WILL BE ERASED. Type YES to continue: " CONFIRM

if [[ "$CONFIRM" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

echo "[2] Rendering disko + boot config for this disk..."
RENDER_DIR="$(mktemp -d)"
"$SCRIPT_DIR/scripts/render-boot-config.sh" "$SCRIPT_DIR" "$DISK" "$BOOT_MODE" "$RENDER_DIR"
DISKO_CONFIG="$RENDER_DIR/disko-config.nix"

echo "[3] Disko plan (dry run, nothing is written yet)..."
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode disko --dry-run "$DISKO_CONFIG"

read -rp "Review the plan above. Type YES to apply it: " CONFIRM_DISKO
if [[ "$CONFIRM_DISKO" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

echo "[4] Applying disko (partition, LUKS, format, mount)..."
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true
cryptsetup close cryptroot 2>/dev/null || true

nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode disko "$DISKO_CONFIG"

echo "[5] Generate hardware config..."
nixos-generate-config --no-filesystems --root /mnt

echo "[6] Copy NixOS flake..."
cp "$SCRIPT_DIR/flake.nix" /mnt/etc/nixos/flake.nix
cp -r "$SCRIPT_DIR/modules" /mnt/etc/nixos/
cp "$DISKO_CONFIG" /mnt/etc/nixos/disko-config.nix

echo "[7] Copy boot.nix..."
cp "$RENDER_DIR/boot.nix" /mnt/etc/nixos/boot.nix

echo "[8] Install..."
NIX_CONFIG="experimental-features = nix-command flakes" \
nixos-install \
  --flake /mnt/etc/nixos#nixos \
  --no-write-lock-file

echo "[9] Set user password..."
nixos-enter --root /mnt -c 'passwd user'

echo "Done. Remove installer media, then reboot."