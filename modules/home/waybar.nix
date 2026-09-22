{ pkgs, ... }:

let
  gpuScript = pkgs.writeShellScript "waybar-gpu.sh" ''
    GPU_PATH="/sys/class/drm/card0/device/gpu_busy_percent"

    if [ -r "$GPU_PATH" ]; then
      usage=$(${pkgs.coreutils}/bin/cat "$GPU_PATH")
      printf '%s\n' "$usage"
    else
      printf '0\n'
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
          "custom/gpu"
        ];

        modules-right = [
          "battery"
          "network"
          "bluetooth"
          "pulseaudio"
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
          interval = 1;
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%H:%M:%S}";
          format-alt = "{:%d.%m.%Y}";
        };

        cpu = {
          format = " {usage}%";
          tooltip = false;
        };

        memory = {
          format = " {}%";
          tooltip-format = "{used:0.1f} GiB / {total:0.1f} GiB";
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

        bluetooth = {
          format = "";
          format-disabled = "";
          format-connected = " {num_connections}";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = "";
          format-ethernet = "";
          format-disconnected = "⚠";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ipaddr}/{cidr}";
          tooltip-format-disconnected = "Disconnected";
        };

        pulseaudio = {
          format = "{icon}";
          format-bluetooth = "{icon}";
          format-bluetooth-muted = "{icon} ";
          format-muted = "󰝟";
          tooltip-format = "Volume: {volume}%";
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

        "custom/gpu" = {
          exec = "${gpuScript}";
          interval = 2;
          format = " {}%";
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
      #bluetooth,
      #pulseaudio,
      #tray,
      #backlight,
      #keyboard-state,
      #language,
      #custom-power {
        padding: 0 10px;
      }

      #cpu,
      #memory,
      #temperature,
      #custom-gpu {
        padding: 0 8px;
        margin: 0;
        border-radius: 6px;
        font-weight: 500;
      }

      #cpu { background: rgba(46,204,113,0.25); }
      #memory { background: rgba(155,89,182,0.25); }
      #temperature { background: rgba(240,147,43,0.25); }
      #temperature.critical { background: rgba(235,77,75,0.35); }
      #custom-gpu { background: rgba(80,120,200,0.25); }

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