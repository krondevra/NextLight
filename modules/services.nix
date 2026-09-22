{ lib, ... }:

{
  fileSystems."/".options = lib.mkAfter [ "noatime" ];
  fileSystems."/home".options = lib.mkAfter [ "noatime" ];

  services.tlp.enable = true;                   # Power Management
  services.tlp.settings = {
    CPU_DRIVER_OPMODE_ON_AC = "active";
    CPU_DRIVER_OPMODE_ON_BAT = "active";

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 1;

    PLATFORM_PROFILE_ON_AC = "balanced";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
    RADEON_DPM_PERF_LEVEL_ON_BAT = "low";

    AMDGPU_ABM_LEVEL_ON_AC = 0;
    AMDGPU_ABM_LEVEL_ON_BAT = 0;

    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "on";

    SOUND_POWER_SAVE_ON_AC = 1;
    SOUND_POWER_SAVE_ON_BAT = 1;

    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";

    RUNTIME_PM_ON_AC = "on";
    RUNTIME_PM_ON_BAT = "auto";

    USB_AUTOSUSPEND = 1;

    NMI_WATCHDOG = 0;
  };

  hardware.sensor.iio.enable = true;            # Sensor Proxy For Orientation

  hardware.bluetooth.enable = true;             # Bluetooth Radio
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;               # Bluetooth Applet + D-Bus Policy

  services.syncthing.enable = true;             # File Synchronization

  virtualisation.libvirtd.enable = true;        # VM Backend
  programs.virt-manager.enable = true;          # VM Manager

  virtualisation.waydroid.enable = true;        # Android Container
}
