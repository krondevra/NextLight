{ lib, ... }:

{
  fileSystems."/".options = lib.mkAfter [ "noatime" ];
  fileSystems."/home".options = lib.mkAfter [ "noatime" ];

  services.power-profiles-daemon.enable = true; # Power Management GUI
  hardware.sensor.iio.enable = true;            # Sensor Proxy For Orientation

  services.syncthing.enable = true;             # File Synchronization

  virtualisation.libvirtd.enable = true;        # VM Backend
  programs.virt-manager.enable = true;          # VM Manager

  virtualisation.waydroid.enable = true;        # Android Container
}
