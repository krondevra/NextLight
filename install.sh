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

if [[ "$BOOT_MODE" == "bios" ]]; then
  if [[ "$DISK" =~ (nvme|mmcblk) ]]; then
    BIOS_PART="${DISK}p1"
    EFI_PART="${DISK}p2"
    ROOT_PART="${DISK}p3"
  else
    BIOS_PART="${DISK}1"
    EFI_PART="${DISK}2"
    ROOT_PART="${DISK}3"
  fi
else
  BIOS_PART=""
  if [[ "$DISK" =~ (nvme|mmcblk) ]]; then
    EFI_PART="${DISK}p1"
    ROOT_PART="${DISK}p2"
  else
    EFI_PART="${DISK}1"
    ROOT_PART="${DISK}2"
  fi
fi

echo
echo "Script dir: $SCRIPT_DIR"
echo "Target disk: $DISK"
if [[ "$BOOT_MODE" == "bios" ]]; then
  echo "BIOS boot partition: $BIOS_PART"
fi
echo "EFI partition: $EFI_PART"
echo "Root/LUKS partition: $ROOT_PART"
read -rp "ALL DATA ON $DISK WILL BE ERASED. Type YES to continue: " CONFIRM

if [[ "$CONFIRM" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

echo "[2] Cleanup..."
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true
cryptsetup close cryptroot 2>/dev/null || true
mkdir -p /mnt

echo "[3] Partitioning..."
parted -s "$DISK" mklabel gpt

if [[ "$BOOT_MODE" == "bios" ]]; then
  parted -s "$DISK" mkpart biosboot 1MiB 3MiB
  parted -s "$DISK" set 1 bios_grub on
  parted -s "$DISK" mkpart ESP fat32 3MiB 515MiB
  parted -s "$DISK" set 2 esp on
  parted -s "$DISK" mkpart primary 515MiB 100%
else
  parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
  parted -s "$DISK" set 1 esp on
  parted -s "$DISK" mkpart primary 513MiB 100%
fi

echo "[4] LUKS..."
cryptsetup luksFormat "$ROOT_PART"
cryptsetup open "$ROOT_PART" cryptroot

echo "[5] Filesystems..."
mkfs.fat -F32 "$EFI_PART"
mkfs.btrfs -f /dev/mapper/cryptroot

echo "[6] Subvolumes..."
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

echo "[7] Mount..."
mount -o subvol=@,compress=zstd /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot /mnt/home
mount -o subvol=@home,compress=zstd /dev/mapper/cryptroot /mnt/home
mount "$EFI_PART" /mnt/boot

echo "[8] Generate hardware config..."
nixos-generate-config --root /mnt

echo "[9] Copy NixOS flake..."
cp "$SCRIPT_DIR/flake.nix" /mnt/etc/nixos/flake.nix
cp -r "$SCRIPT_DIR/modules" /mnt/etc/nixos/

echo "[10] Generate boot.nix..."
if [[ "$BOOT_MODE" == "uefi" ]]; then
  cat > /mnt/etc/nixos/boot.nix <<'EOF'
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
  cat > /mnt/etc/nixos/boot.nix <<EOF
{ ... }:
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "$DISK";
  boot.loader.grub.useOSProber = true;
}
EOF
fi

echo "[11] Check generated LUKS config..."
grep -n "boot.initrd.luks.devices" /mnt/etc/nixos/hardware-configuration.nix || true

echo "[12] Install..."
NIX_CONFIG="experimental-features = nix-command flakes" \
nixos-install \
  --flake /mnt/etc/nixos#nixos \
  --no-write-lock-file

echo "[13] Set user password..."
nixos-enter --root /mnt -c 'passwd user'

echo "Done. Remove installer media, then reboot."