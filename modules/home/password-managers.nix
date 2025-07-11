{ pkgs, ...}:
{    # Install Bitwarden desktop
    home.packages = with pkgs; [
      bitwarden-desktop
    ];
}
