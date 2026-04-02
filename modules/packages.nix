{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btrfs-progs               # Filesystem Btrfs
    code                      # IDE For Development
    curl                      # Data Transfer Tool
    discord                   # Communication Platform
    #dnsmasq                  # VM DNS/DHCP Server
    dunst                     # HYPR Notification Daemon
    exfatprogs                # Filesystem ExFAT
    fastfetch                 # About System
    ffmpeg                    # Multimedia Framework
    firefox                   # Web Browser
    gimp                      # Image Editor
    git                       # Version Control
    grim                      # HYPR Wayland Screenshot Tool
    hyprpaper                 # HYPR Wallpaper Utility
    kdePackages.kdenlive      # KDE Video Editor
    keepassxc                 # Password Manager
    kitty                     # HYPR GPU Accelerated Terminal
    lazygit                   # Console Git UI
    libreoffice-still         # Office Suite
    mangohud                  # Game Performance Overlay
    mpv                       # Media Player
    obs-studio                # Streaming And Recording Software
    obsidian                  # Note-Taking Application
    ollama                    # Run LLMs
    pavucontrol               # Audio Control GUI
    qemu                      # VM Emulator Backend
    qt5.qtwayland             # HYPR Qt5 Wayland Support
    qt6.qtwayland             # HYPR Qt6 Wayland Support
    rstudio                   # RStudio IDE
    slurp                     # HYPR Screen Region Selector
    swayimg                   # Wayland Image Viewer
    telegram-desktop          # Messaging Application
    tree                      # Directory Tree Viewer
    vim                       # Text Editor
    waybar                    # HYPR Status Bar
    wget                      # File Downloader
    wl-clipboard              # HYPR Clipboard Tool
    wofi                      # HYPR Application Launcher
    yt-dlp                    # Video Downloader
  ];
}
