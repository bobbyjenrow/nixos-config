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
      "default" = {
        ids = [ "*" ];
        settings = {
          main = {
            # Home row modifiers using lettermod
            a = "lettermod(meta, a, 150, 250)";
            s = "lettermod(alt, s, 150, 250)";
            d = "lettermod(control, d, 150, 250)";
            f = "lettermod(shift, f, 150, 250)";

            j = "lettermod(shift, j, 150, 250)";
            k = "lettermod(control, k, 150, 250)";
            l = "lettermod(alt, l, 150, 250)";
            semicolon = "lettermod(meta, semicolon, 150, 250)";

            # Spacebar navigation layer
            space = "overload(nav, space)";
          };

          # Navigation layer - activated by holding spacebar
          nav = {
            # Vim-style navigation
            h = "left";
            j = "down";
            k = "up";
            l = "right";

            # Brackets and symbols
            "1" = "[";
            "4" = "]";
            "2" = "(";
            "3" = ")";
            w = "{";
            e = "}";
          };
        };
      };
    };
  };

  # Additional information
  environment.etc."keyd/README".text = ''
    Keyd Home Row Mods Configuration
    ===============================

    This configuration implements home row modifier keys using lettermod
    and a spacebar navigation layer:

    HOME ROW MODIFIERS:
    Left hand:
    - a (hold) = Super/Windows key, (tap) = a
    - s (hold) = Alt key, (tap) = s
    - d (hold) = Ctrl key, (tap) = d
    - f (hold) = Shift key, (tap) = f

    Right hand:
    - j (hold) = Shift key, (tap) = j
    - k (hold) = Ctrl key, (tap) = k
    - l (hold) = Alt key, (tap) = l
    - ; (hold) = Super/Windows key, (tap) = ;

    SPACEBAR NAVIGATION LAYER:
    - space (hold) = navigation layer, (tap) = space

    When holding spacebar:
    - h/j/k/l = arrow keys (left/down/up/right)
    - 1/4 = [ and ]
    - 2/3 = ( and )
    - w/e = { and }

    Timing:
    - Idle timeout: 150ms (time to detect if typing mid-word)
    - Hold timeout: 250ms (time to hold for modifier activation)

    To check if keyd is working:
    - sudo systemctl status keyd
    - sudo keyd monitor (to see key events)

    To reload configuration:
    - sudo systemctl reload keyd

    Configuration files: /etc/keyd/*.conf
  '';
}
