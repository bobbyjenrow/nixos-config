{
  config,
  lib,
  pkgs,
  input,
  ...
}:
{

  # Install keyd package
  environment.systemPackages = with pkgs; [
    keyd
  ];

  # Enable keyd service
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids =
          if input.keyd.laptopOnly then
            [
              # Target laptop built-in keyboards by common patterns
              # This excludes most external keyboards while catching built-in ones
              "*AT*keyboard*"
            ]
          else
            [ "*" ];

        settings = {
          main = {
            # Home row mods configuration
            # Left hand: a=super, s=alt, d=ctrl, f=shift
            # Right hand: j=shift, k=ctrl, l=alt, ;=super

            # Left hand home row mods
            a = "overload(super, a)";
            s = "overload(alt, s)";
            d = "overload(control, d)";
            f = "overload(shift, f)";

            # Right hand home row mods
            j = "overload(shift, j)";
            k = "overload(control, k)";
            l = "overload(alt, l)";
            semicolon = "overload(super, semicolon)";

            # Timeout settings for better responsiveness
            # These can be tuned based on your typing style
            overload_tap_timeout = "200";
            overload_hold_timeout = "200";
          };
        };
      };
    };
  };

  # Ensure keyd service starts early and is available
  systemd.services.keyd = {
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-user-sessions.service" ];

    serviceConfig = {
      # Run with appropriate permissions
      User = "root";
      Group = "root";

      # Restart policy
      Restart = "always";
      RestartSec = "5";

      # Security settings
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;

      # Allow access to input devices
      DevicePolicy = "closed";
      DeviceAllow = [
        "/dev/input/event* rw"
        "/dev/uinput rw"
      ];
    };
  };

  # Add user to input group for keyd access
  users.groups.keyd = {
    name = "keyd";
  };

  # Create udev rules for proper device permissions
  services.udev.extraRules = ''
    # Allow keyd access to input devices
    KERNEL=="event[0-9]*", GROUP="input", MODE="0660"
    KERNEL=="uinput", GROUP="input", MODE="0660"

    # Ensure keyd can access input devices
    SUBSYSTEM=="input", GROUP="input", MODE="0660"
    SUBSYSTEM=="misc", KERNEL=="uinput", GROUP="input", MODE="0660"
  '';

  # Load uinput module
  boot.kernelModules = [ "uinput" ];

  # Ensure proper permissions for uinput device
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1; # Enable SysRq for debugging if needed
  };

  # Warning about external keyboards
  warnings = lib.optionals (input.keyd.enable && input.keyd.laptopOnly) [
    "Keyd is configured for laptop-only mode. External keyboards should not be affected, but you may need to adjust the keyboard IDs if the configuration doesn't work as expected."
  ];

  # Additional information
  environment.etc."keyd/README".text = ''
    Keyd Home Row Mods Configuration
    ===============================

    This configuration implements home row modifier keys:

    Left hand:
    - a (hold) = Super/Windows key
    - s (hold) = Alt key
    - d (hold) = Ctrl key
    - f (hold) = Shift key

    Right hand:
    - j (hold) = Shift key
    - k (hold) = Ctrl key
    - l (hold) = Alt key
    - ; (hold) = Super/Windows key

    Timing:
    - Tap timeout: 200ms
    - Hold timeout: 200ms

    To check if keyd is working:
    - sudo systemctl status keyd
    - sudo keyd monitor (to see key events)

    To reload configuration:
    - sudo systemctl reload keyd

    Configuration file: /etc/keyd/default.conf
  '';
}
