{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix

    ./modules/user.nix
    ./modules/desktop-hyprland.nix
    ./modules/sound.nix
    ./modules/services.nix
    ./modules/packages.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Riga";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "25.11";
}
