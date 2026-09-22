{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, disko, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules =
        [
          ./modules/user.nix
          ./modules/hardware.nix
          ./modules/desktop-hyprland.nix
          ./modules/sound.nix
          ./modules/services.nix
          ./modules/packages.nix
          # ./modules/packages-extra.nix

          disko.nixosModules.disko
          ./disko-config.nix

          home-manager.nixosModules.home-manager

          ({ ... }: {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            networking.hostName = "nixos";
            networking.networkmanager.enable = true;

            time.timeZone = "Europe/Riga";
            i18n.defaultLocale = "en_US.UTF-8";

            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.permittedInsecurePackages = [
              "electron-38.8.4"
            ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.user = {
              imports = [
                ./modules/home/hyprland.nix
                ./modules/home/kitty.nix
                ./modules/home/mpv.nix
                ./modules/home/fastfetch.nix
                ./modules/home/zsh.nix
                ./modules/home/waybar.nix
                ./modules/home/hypridle.nix
                ./modules/home/hyprlock.nix
              ];
              home.stateVersion = "25.11";
            };

            system.stateVersion = "25.11";
          })
        ]
        ++ builtins.filter builtins.pathExists [
          ./hardware-configuration.nix
          ./boot.nix
        ];
    };
  };
}