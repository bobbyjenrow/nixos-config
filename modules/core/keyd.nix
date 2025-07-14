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
      "atkbd" = {
        ids = [ "*" ];  # Apply to all keyboards temporarily
        settings = {
          global = {
            overload_timeout = "150";
          };
          main = {
            a = "lettermod(leftmeta, a, 150, 200)";
            s = "lettermod(leftalt, s, 150, 200)";
            d = "lettermod(leftctrl, d, 150, 200)";
            f = "lettermod(leftshift, f, 150, 200)";

            j = "lettermod(rightshift, j, 150, 200)";
            k = "lettermod(rightctrl, k, 150, 200)";
            l = "lettermod(rightalt, l, 150, 200)";
            semicolon = "overloadt2(rightmeta, semicolon, 200)";
          };
        };
      };
    };
  };


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
