{ pkgs, ... }:

{
  programs.hyprland = {
  enable = true;
  package = pkgs.hyprland;
};

  services.greetd.enable = true;
  services.greetd.settings.default_session = {
    command = "${pkgs.hyprland}/bin/Hyprland";
    user = "user";
  };

  security.polkit.enable = true;
  services.dbus.enable = true;
  programs.dconf.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland # Desktop Portal
    xdg-desktop-portal-gtk      # Portal Backend
  ];
}
