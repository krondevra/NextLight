{ pkgs, ... }:

let
  igpuScript = pkgs.writeShellScript "waybar-igpu.sh" ''
    GPU_PATH="/sys/class/drm/card0/device/gpu_busy_percent"

    if [ -r "$GPU_PATH" ]; then
      usage=$(${pkgs.coreutils}/bin/cat "$GPU_PATH")
      printf '%s\n' "$usage"
    else
      printf '0\n'
    fi
  '';

  egpuScript = pkgs.writeShellScript "waybar-egpu.sh" ''
    GPU_PATH="/sys/class/drm/card1/device/gpu_busy_percent"

    if [ -r "$GPU_PATH" ]; then
      usage=$(${pkgs.coreutils}/bin/cat "$GPU_PATH")
      printf '{"text":"%s%%","class":"connected"}\n' "$usage"
    else
      printf '{"text":"","class":"disconnected"}\n'
    fi
  '';

  powerMenuXml = pkgs.writeText "power_menu.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <interface>
      <object class="GtkMenu" id="menu">
        <child>
          <object class="GtkMenuItem" id="logout">
            <property name="label">Log Out</property>
          </object>
        </child>
        <child>
          <object class="GtkMenuItem" id="shutdown">
            <property name="label">Shutdown</property>
          </object>
        </child>
        <child>
          <object class="GtkSeparatorMenuItem" id="delimiter1"/>
        </child>
        <child>
          <object class="GtkMenuItem" id="reboot">
            <property name="label">Reboot</property>
          </object>
        </child>
      </object>
    </interface>
  '';
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        height = 30;
        spacing = 4;

        modules-left = [
          "hyprland/workspaces"
        ];

        modules-center = [
          "temperature"
          "memory"
          "cpu"
          "custom/igpu"
          "custom/egpu"
        ];

        modules-right = [
          "battery"
          "pulseaudio"
          "network"
          "power-profiles-daemon"
          "backlight"
          "keyboard-state"
          "hyprland/language"
          "clock"
          "tray"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          persistent-workspaces = {
            "*" = [ 1 2 3 4 5 6 7 8 9 ];
          };
        };

        "hyprland/language" = {
          format = "{}";
          format-en = "us";
          format-ru = "ru";
          keyboard-name = "at-translated-set-2-keyboard";
        };

        "keyboard-state" = {
          numlock = true;
          capslock = true;
          format = "{name} {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };

        tray = {
          spacing = 10;
        };

        clock = {
          timezone = "Europe/Riga";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d}";
        };

        cpu = {
          format = " {usage}%";
          tooltip = false;
        };

        memory = {
          format = " {}%";
        };

        temperature = {
          critical-threshold = 80;
          format = "{icon} {temperatureC}°C";
          format-icons = [ "" "" "" ];
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };

        network = {
          format-wifi = "";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{icon} {volume}% {format_source}";
          format-bluetooth-muted = "{icon}  {format_source}";
          format-muted = "󰝟 {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        "custom/power" = {
          format = "⏻ ";
          tooltip = false;
          menu = "on-click";
          menu-file = "${powerMenuXml}";
          menu-actions = {
            shutdown = "systemctl poweroff";
            reboot = "systemctl reboot";
            logout = "hyprctl dispatch exit";
          };
        };

        "custom/igpu" = {
          exec = "${igpuScript}";
          interval = 2;
          format = "iGPU {}";
          tooltip = false;
        };

        "custom/egpu" = {
          exec = "${egpuScript}";
          interval = 2;
          return-type = "json";
          format = "eGPU {text}";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 13px;
      }

      window#waybar {
        background: rgba(43,48,59,0.6);
        color: #e6e6e6;
      }

      #clock,
      #battery,
      #network,
      #pulseaudio,
      #tray,
      #power-profiles-daemon,
      #backlight,
      #keyboard-state,
      #language,
      #custom-power {
        padding: 0 10px;
      }

      #cpu,
      #memory,
      #temperature,
      #custom-igpu,
      #custom-egpu.connected {
        padding: 0 8px;
        margin: 0;
        border-radius: 6px;
        font-weight: 500;
      }

      #cpu { background: rgba(46,204,113,0.25); }
      #memory { background: rgba(155,89,182,0.25); }
      #temperature { background: rgba(240,147,43,0.25); }
      #temperature.critical { background: rgba(235,77,75,0.35); }
      #custom-igpu { background: rgba(80,120,200,0.25); }
      #custom-egpu.connected { background: rgba(200,120,80,0.25); }

      #custom-egpu.disconnected {
        opacity: 0;
        padding: 0;
        margin: 0;
        min-width: 0;
      }

      #clock {
        background: rgba(100,114,125,0.35);
        border-radius: 6px;
        margin: 0 4px;
      }

      #workspaces {
        background: rgba(100,114,125,0.35);
        border-radius: 6px;
        margin: 0 4px;
        padding: 0 6px;
      }

      #workspaces button {
        background: transparent;
        border: none;
        padding: 0 6px;
        color: #ff5555;
        font-weight: 500;
      }

      #workspaces button.active {
        color: #ffffff;
        font-weight: 700;
      }

      #workspaces button:hover {
        background: rgba(255,255,255,0.15);
        border-radius: 4px;
      }
    '';
  };
}