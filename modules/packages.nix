{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    brightnessctl             # Backlight Control CLI
    curl                      # Data Transfer Tool
    dunst                     # Notification Daemon
    fastfetch                 # About System
    firefox                   # Web Browser
    git                       # Version Control
    grim                      # Wayland Screenshot Tool
    hypridle                  # Hyprland Idle Daemon
    hyprlock                  # Hyprland Lock Screen
    hyprpaper                 # Wallpaper Utility
    kitty                     # GPU Accelerated Terminal
    pavucontrol               # Audio Control GUI
    slurp                     # Screen Region Selector
    swayimg                   # Wayland Image Viewer
    tree                      # Directory Tree Viewer
    neovim                    # Text Editor
    yazi                      # File Manager
    waybar                    # Status Bar
    wget                      # File Downloader
    wl-clipboard              # Clipboard Tool
    wofi                      # Application Launcher
    networkmanagerapplet
  ];
}
