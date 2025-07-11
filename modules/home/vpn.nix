{ config, lib, pkgs, ... }:

{

    # VPN management scripts
    home.packages = with pkgs; [
      # Network monitoring tools
      networkmanager-applet

      # VPN GUI tools
      mullvad-vpn

      # System tray utilities
      libnotify

      # Custom VPN management scripts
      (writeShellScriptBin "vpn-toggle" ''
        #!/bin/bash

        # VPN toggle script with notifications
        VPN_SERVICE="mullvad-wg"

        if systemctl is-active --quiet "$VPN_SERVICE"; then
          echo "Stopping VPN..."
          sudo systemctl stop "$VPN_SERVICE"
          ${if config.bobbynix.home.desktop.vpn.mullvad.showNotifications then ''
            notify-send "VPN" "Mullvad VPN disconnected" --icon=network-vpn-symbolic
          '' else ""}
        else
          echo "Starting VPN..."
          sudo systemctl start "$VPN_SERVICE"
          sleep 2
          if systemctl is-active --quiet "$VPN_SERVICE"; then
            ${if config.bobbynix.home.desktop.vpn.mullvad.showNotifications then ''
              notify-send "VPN" "Mullvad VPN connected" --icon=network-vpn-symbolic
            '' else ""}
          else
            ${if config.bobbynix.home.desktop.vpn.mullvad.showNotifications then ''
              notify-send "VPN" "Failed to connect to Mullvad VPN" --icon=dialog-error
            '' else ""}
          fi
        fi
      '')

      (writeShellScriptBin "vpn-status-check" ''
        #!/bin/bash

        # VPN status checker for system tray and HyprPanel
        VPN_SERVICE="mullvad-wg"

        if systemctl is-active --quiet "$VPN_SERVICE"; then
          echo "🔒"
          exit 0
        else
          echo "🔓"
          exit 1
        fi
      '')

      (writeShellScriptBin "vpn-status-text" ''
        #!/bin/bash

        # VPN status with text for detailed display
        VPN_SERVICE="mullvad-wg"

        if systemctl is-active --quiet "$VPN_SERVICE"; then
          echo "🔒 VPN Connected"
          exit 0
        else
          echo "🔓 VPN Disconnected"
          exit 1
        fi
      '')

      (writeShellScriptBin "vpn-ip-check" ''
        #!/bin/bash

        # Check current IP and VPN status
        echo "Checking VPN status..."

        # Get current IP
        CURRENT_IP=$(curl -s --max-time 5 https://ipinfo.io/ip || echo "Unable to determine")

        # Check if VPN is running
        if systemctl is-active --quiet mullvad-wg; then
          echo "🔒 VPN Status: Connected"
          echo "📍 Current IP: $CURRENT_IP"

          # Check if this looks like a Mullvad IP
          LOCATION=$(curl -s --max-time 5 https://ipinfo.io/city || echo "Unknown")
          echo "📍 Location: $LOCATION"
        else
          echo "🔓 VPN Status: Disconnected"
          echo "📍 Current IP: $CURRENT_IP"
          echo "⚠️  Warning: Traffic is not protected by VPN"
        fi
      '')
    ];

    # Desktop entries for VPN management
    xdg.desktopEntries = {
      vpn-toggle = {
        name = "Toggle VPN";
        comment = "Toggle Mullvad VPN connection";
        exec = "vpn-toggle";
        icon = "network-vpn-symbolic";
        categories = [ "Network" "System" ];
        terminal = false;

        actions = {
          connect = {
            name = "Connect VPN";
            exec = "sudo systemctl start mullvad-wg";
          };
          disconnect = {
            name = "Disconnect VPN";
            exec = "sudo systemctl stop mullvad-wg";
          };
          status = {
            name = "Check Status";
            exec = "vpn-ip-check";
          };
        };
      };

      vpn-status = {
        name = "VPN Status";
        comment = "Check VPN connection status";
        exec = "vpn-ip-check";
        icon = "network-vpn-symbolic";
        categories = [ "Network" "System" ];
        terminal = true;
      };
    };

    # HyprPanel integration (if using HyprPanel)
    xdg.configFile."hyprpanel/vpn-module.json" = mkIf (config.bobbynix.home.desktop.hyprpanel.enable or false) {
      text = builtins.toJSON {
        vpn = {
          label = "🔒";
          pollingInterval = 5000; # 5 seconds
          exec = "vpn-status-check";
          on-click = "vpn-toggle";
          tooltip = "Click to toggle VPN";
          class = "vpn-module";
        };
      };
    };

    # Waybar integration (if using Waybar)
    programs.waybar = mkIf (config.programs.waybar.enable or false) {
      settings = {
        mainBar = {
          modules-right = mkAfter [ "custom/vpn" ];

          "custom/vpn" = {
            format = "{}";
            exec = "vpn-status-check";
            interval = 30;
            tooltip = true;
            tooltip-format = "Click to toggle VPN";
            on-click = "vpn-toggle";
            signal = 8;
          };
        };
      };
    };

    # Notification service configuration with Stylix integration
    services.dunst = mkIf config.bobbynix.home.desktop.vpn.mullvad.showNotifications {
      enable = mkDefault true;
      settings = mkMerge [
        (mkIf (config.bobbynix.theme.enable or false) {
          global = {
            follow = "mouse";
            geometry = "300x50-20+48";
            transparency = 10;
            frame_color = "#${config.lib.stylix.colors.base0D}";
            separator_color = "frame";
          };

          urgency_low = {
            background = "#${config.lib.stylix.colors.base00}";
            foreground = "#${config.lib.stylix.colors.base05}";
            timeout = 5;
          };

          urgency_normal = {
            background = "#${config.lib.stylix.colors.base00}";
            foreground = "#${config.lib.stylix.colors.base05}";
            timeout = 10;
          };

          urgency_critical = {
            background = "#${config.lib.stylix.colors.base00}";
            foreground = "#${config.lib.stylix.colors.base08}";
            timeout = 0;
          };
        })
        (mkIf (!config.bobbynix.theme.enable or false) {
          global = {
            follow = "mouse";
            geometry = "300x50-20+48";
            transparency = 10;
            frame_color = "#89B4FA";
            separator_color = "frame";
          };

          urgency_low = {
            background = "#1E1E2E";
            foreground = "#CDD6F4";
            timeout = 5;
          };

          urgency_normal = {
            background = "#1E1E2E";
            foreground = "#CDD6F4";
            timeout = 10;
          };

          urgency_critical = {
            background = "#1E1E2E";
            foreground = "#F38BA8";
            timeout = 0;
          };
        })
      ];
    };

    # Systemd user service for VPN monitoring
    systemd.user.services.vpn-monitor = mkIf config.bobbyj.home.desktop.vpn.mullvad.showNotifications {
      Unit = {
        Description = "VPN Connection Monitor";
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "vpn-monitor" ''
          #!/bin/bash

          # Monitor VPN connection status
          VPN_SERVICE="mullvad-wg"
          LAST_STATE=""

          while true; do
            if systemctl is-active --quiet "$VPN_SERVICE"; then
              CURRENT_STATE="connected"
              if [ "$LAST_STATE" != "connected" ]; then
                notify-send "VPN" "Mullvad VPN connected" --icon=network-vpn-symbolic
                LAST_STATE="connected"
              fi
            else
              CURRENT_STATE="disconnected"
              if [ "$LAST_STATE" != "disconnected" ] && [ -n "$LAST_STATE" ]; then
                notify-send "VPN" "Mullvad VPN disconnected" --icon=network-vpn-symbolic
                LAST_STATE="disconnected"
              elif [ -z "$LAST_STATE" ]; then
                LAST_STATE="disconnected"
              fi
            fi

            sleep 10
          done
        '';
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Hyprland integration (if using Hyprland)
    wayland.windowManager.hyprland = mkIf (config.wayland.windowManager.hyprland.enable or false) {
      settings = {
        bind = [
          # VPN toggle keybinding
          "SUPER_SHIFT, V, exec, vpn-toggle"
          # VPN status keybinding
          "SUPER_SHIFT, CTRL_V, exec, vpn-ip-check"
        ];
      };
    };

    # HyprPanel custom CSS for VPN module with Stylix integration
    xdg.configFile."hyprpanel/vpn-styles.css" = mkIf (config.bobbyj.home.desktop.hyprpanel.enable or false) {
      text = with config.lib.stylix.colors; ''
        .vpn-module {
          color: ${if (config.bobbynix.theme.enable or false) then "#${base0B}" else "#a6e3a1"};
          background-color: ${if (config.bobbynix.theme.enable or false) then "rgba(${toString (lib.toInt "0x${base0B}")}, 0.1)" else "rgba(166, 227, 161, 0.1)"};
          border-radius: 8px;
          padding: 4px 8px;
          margin: 2px;
          transition: all 0.3s ease;
          border: 1px solid ${if (config.bobbynix.theme.enable or false) then "#${base03}" else "rgba(166, 227, 161, 0.3)"};
        }

        .vpn-module:hover {
          background-color: ${if (config.bobbynix.theme.enable or false) then "rgba(${toString (lib.toInt "0x${base0B}")}, 0.2)" else "rgba(166, 227, 161, 0.2)"};
          transform: scale(1.05);
          border-color: ${if (config.bobbynix.theme.enable or false) then "#${base0B}" else "#a6e3a1"};
        }

        .vpn-module.disconnected {
          color: ${if (config.bobbynix.theme.enable or false) then "#${base08}" else "#f38ba8"};
          background-color: ${if (config.bobbynix.theme.enable or false) then "rgba(${toString (lib.toInt "0x${base08}")}, 0.1)" else "rgba(243, 139, 168, 0.1)"};
          border-color: ${if (config.bobbynix.theme.enable or false) then "#${base08}" else "rgba(243, 139, 168, 0.3)"};
        }

        .vpn-module.disconnected:hover {
          background-color: ${if (config.bobbynix.theme.enable or false) then "rgba(${toString (lib.toInt "0x${base08}")}, 0.2)" else "rgba(243, 139, 168, 0.2)"};
          border-color: ${if (config.bobbynix.theme.enable or false) then "#${base08}" else "#f38ba8"};
        }
      '';
    };

    # Shell aliases for VPN management
    programs.zsh = mkIf (config.programs.zsh.enable or false) {
      shellAliases = {
        vpn = "vpn-toggle";
        vpn-on = "sudo systemctl start mullvad-wg";
        vpn-off = "sudo systemctl stop mullvad-wg";
        vpn-check = "vpn-ip-check";
        vpn-logs = "sudo journalctl -u mullvad-wg -f";
      };
    };

    # Mullvad app configuration with Stylix theme integration
    home.file.".config/Mullvad VPN/gui_settings.json" = mkIf config.bobbynix.home.desktop.vpn.mullvad.enable {
      text = builtins.toJSON {
        autoConnect = false;
        autoStart = false;
        enableSystemNotifications = config.bobbynix.home.desktop.vpn.mullvad.showNotifications;
        showBetaReleases = false;
        theme = if (config.bobbynix.theme.enable or false) then
          (if config.lib.stylix.colors.base00 == "000000" then "dark" else "light")
          else "dark";
        preferredLocale = "en";

        # Security settings
        blockWhenDisconnected = true;
        enableIpv6 = true;
        bridgeSettings = {
          normal = {
            location = "any";
          };
        };

        # Tunnel settings
        tunnelOptions = {
          openvpn = {
            mssfix = null;
          };
          wireguard = {
            mtu = null;
          };
          generic = {
            enableIpv6 = true;
          };
        };
      };
    };

    # Font configuration for VPN apps
    fonts.fontconfig.enable = mkDefault true;

    # Assertions for proper configuration
    assertions = [
      {
        assertion = config.bobbynix.home.desktop.vpn.mullvad.enable -> config.bobbynix.home.desktop.vpn.enable;
        message = "Mullvad VPN desktop integration requires general VPN desktop integration to be enabled.";
      }
    ];

    # Warnings for user attention
    warnings = mkIf config.bobbynix.home.desktop.vpn.enable [
      "VPN desktop integration is enabled. Make sure the system-level VPN configuration is properly set up."
    ] ++ lib.optionals (config.bobbynix.home.desktop.vpn.enable && !config.bobbynix.theme.enable or false) [
      "VPN desktop integration is enabled but theming is not. Consider enabling bobbynix.theme for consistent styling."
    ];

    # Stylix integration for VPN components
    stylix.targets = mkIf (config.bobbynix.theme.enable or false) {
      dunst.enable = mkDefault true;
      gtk.enable = mkDefault true;
      qt.enable = mkDefault true;
    };
  };
}
