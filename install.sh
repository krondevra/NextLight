#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

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

echo "[9] Write configuration.nix..."
if [[ "$BOOT_MODE" == "uefi" ]]; then
  BOOT_CFG='
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;'
else
  BOOT_CFG="
  boot.loader.grub.enable = true;
  boot.loader.grub.device = \"$DISK\";
  boot.loader.grub.useOSProber = true;"
fi

cat > /mnt/etc/nixos/configuration.nix <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Riga";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "us";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
$BOOT_CFG

  system.stateVersion = "25.11";
}
EOF

echo "[10] Check generated LUKS config..."
grep -n "boot.initrd.luks.devices" /mnt/etc/nixos/hardware-configuration.nix || true

echo "[11] Install..."
nixos-install

echo "[12] Set user password..."
nixos-enter --root /mnt -c 'passwd user'

echo "Done. Remove installer media, then reboot."
