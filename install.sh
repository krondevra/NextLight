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

if [[ "$DISK" =~ (nvme|mmcblk) ]]; then
  BIOS_PART="${DISK}p1"
  EFI_PART="${DISK}p2"
  ROOT_PART="${DISK}p3"
else
  BIOS_PART="${DISK}1"
  EFI_PART="${DISK}2"
  ROOT_PART="${DISK}3"
fi

echo
echo "Script dir: $SCRIPT_DIR"
echo "Target disk: $DISK"
echo "BIOS boot partition: $BIOS_PART"
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
parted -s "$DISK" mkpart biosboot 1MiB 3MiB
parted -s "$DISK" set 1 bios_grub on
parted -s "$DISK" mkpart ESP fat32 3MiB 515MiB
parted -s "$DISK" set 2 esp on
parted -s "$DISK" mkpart primary 515MiB 100%

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

echo "[9] Copy NixOS config..."
cp "$SCRIPT_DIR/configuration.nix" /mnt/etc/nixos/configuration.nix
cp -r "$SCRIPT_DIR/modules" /mnt/etc/nixos/

if [[ "$BOOT_MODE" == "uefi" ]]; then
  cp "$SCRIPT_DIR/boot-uefi.nix" /mnt/etc/nixos/boot.nix
else
  sed "s|__DISK__|$DISK|g" "$SCRIPT_DIR/boot-bios.nix.in" > /mnt/etc/nixos/boot.nix
fi

echo "[10] Check generated LUKS config..."
grep -n "boot.initrd.luks.devices" /mnt/etc/nixos/hardware-configuration.nix || true

echo "[11] Copy dotfiles..."
mkdir -p /mnt/home/user
cp -r "$SCRIPT_DIR/dotfiles/." /mnt/home/user/

chown -R 1000:100 /mnt/home/user

echo "[12] Install..."
nixos-install

echo "[13] Set user password..."
nixos-enter --root /mnt -c 'passwd user'

echo "Done. Remove installer media, then reboot."
