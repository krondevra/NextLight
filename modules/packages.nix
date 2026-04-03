{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl                      # Data Transfer Tool
    dunst                     # Notification Daemon
    fastfetch                 # About System
    firefox                   # Web Browser
    git                       # Version Control
    grim                      # Wayland Screenshot Tool
    hyprpaper                 # Wallpaper Utility
    kitty                     # GPU Accelerated Terminal
    pavucontrol               # Audio Control GUI
    slurp                     # Screen Region Selector
    swayimg                   # Wayland Image Viewer
    tree                      # Directory Tree Viewer
    vim                       # Text Editor
    waybar                    # Status Bar
    wget                      # File Downloader
    wl-clipboard              # Clipboard Tool
    wofi                      # Application Launcher
  ];
}
