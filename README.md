# NixOS-installer

A personal NixOS flake: an installer plus a Hyprland desktop configuration,
managed declaratively through `nixosConfigurations` + home-manager.

## Layout

- `install.sh` — run from the NixOS live ISO. Detects boot mode (UEFI/BIOS),
  prompts for a target disk, then hands partitioning/LUKS/btrfs setup to
  [disko](https://github.com/nix-community/disko) before running
  `nixos-install`.
- `disko-config.nix` — declarative disk layout template (GPT, LUKS2-encrypted
  root, btrfs with `@`/`@home` subvolumes, `compress=zstd`). `install.sh`
  substitutes the real disk device into it before applying, and copies the
  rendered version into `/mnt/etc/nixos/` so later rebuilds keep working.
- `flake.nix` — wires together the system modules, disko, and home-manager.
  Conditionally imports `hardware-configuration.nix` and `boot.nix` (both
  generated at install time) so the flake also evaluates cleanly straight
  from a checkout, pre-install.
- `modules/*.nix` — system-level NixOS configuration: user account
  (`user.nix`), Hyprland + greetd session (`desktop-hyprland.nix`), pipewire
  audio (`sound.nix`), misc services (`services.nix`), and package lists
  split into a core set (`packages.nix`) and an optional larger set
  (`packages-extra.nix`, currently commented out in `flake.nix`).
- `modules/home/*` — home-manager modules for the desktop: Hyprland itself
  (`hyprland.nix`), the status bar (`waybar.nix`), terminal (`kitty.nix`),
  shell (`zsh.nix` + `p10k.zsh` for the prompt), `mpv.nix`, and `fastfetch.nix`.

## Usage

Boot the NixOS live ISO, clone this repo, and run `sudo ./install.sh`. It
will show you the disko plan for your chosen disk before touching anything,
and asks for a second confirmation before applying it.

To iterate on the config after install, edit `modules/` on the installed
system and run `sudo nixos-rebuild switch --flake /etc/nixos#nixos`.

## Status

- **Verified end-to-end in a VM:** disk partitioning/LUKS/btrfs, base system
  boot, Hyprland session startup, pipewire audio.
- **Code-reviewed only, not yet re-verified after the disko migration:** the
  full install path from `install.sh` through `nixos-install` — the previous
  imperative `parted`/`cryptsetup`/`mkfs` version was VM-tested, but disko
  now owns that step and hasn't been run end-to-end yet.
- **Known broken:** waybar's power-menu buttons (shutdown/reboot/logout) are
  wired up but don't work yet.

## Versioning

Commits follow `N.XX.YY`: `N` is the generation (a from-scratch rethink of
the project), `XX` is the feature area, `YY` is a sequential value within
that area. Generation 1 (`1.xx.yy`) was the original imperative-partitioning,
dotfiles-then-home-manager build. Generation 2 (`2.xx.yy`) starts here, and
folds in reproducibility lessons learned from porting this project to Arch
and back: disko instead of hand-rolled disk scripts, and this README's
status-tracking convention instead of over-claiming.

Area codes: `01` meta/docs, `02` installer, `03` NixOS system modules, `04`
home-manager/desktop config.
