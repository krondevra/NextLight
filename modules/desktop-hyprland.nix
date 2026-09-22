{ pkgs, ... }:

{
  programs.hyprland = {
  enable = true;
  package = pkgs.hyprland;
};

  services.greetd.enable = true;
  services.greetd.useTextGreeter = true;
  services.greetd.settings.default_session = {
    command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/Hyprland";
    user = "greeter";
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
