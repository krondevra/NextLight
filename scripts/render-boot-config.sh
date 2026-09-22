#!/usr/bin/env bash
# Renders disko-config.nix and boot.nix for a given disk + boot mode.
# Shared by install.sh (real install) and CI (validates both boot modes
# against a fake disk without needing a real machine).
set -euo pipefail

SCRIPT_DIR="$1"  # directory containing the disko-config.nix template
DISK="$2"
BOOT_MODE="$3"   # uefi | bios
OUT_DIR="$4"     # where to write disko-config.nix and boot.nix

BIOS_BOOT_PARTITION=""
if [[ "$BOOT_MODE" == "bios" ]]; then
  BIOS_BOOT_PARTITION='bios-boot = {
          size = "1M";
          type = "EF02";
        };'
fi

awk -v block="$BIOS_BOOT_PARTITION" '{gsub(/##BIOS_BOOT_PARTITION##/, block); print}' \
  "$SCRIPT_DIR/disko-config.nix" | sed "s|@DISK@|$DISK|g" > "$OUT_DIR/disko-config.nix"

if [[ "$BOOT_MODE" == "uefi" ]]; then
  cat > "$OUT_DIR/boot.nix" <<'EOF'
{ ... }:
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
EOF
else
  # Don't set boot.loader.grub.device here: disko already configures
  # boot.loader.grub.devices from the EF02 (bios-boot) partition. Setting
  # both causes the same disk to appear twice in mirroredBoots and trips
  # the "duplicated devices in mirroredBoots" assertion.
  cat > "$OUT_DIR/boot.nix" <<'EOF'
{ ... }:
{
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
}
EOF
fi
