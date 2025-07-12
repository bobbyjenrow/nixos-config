{ ... }:
{
  imports = [
    ./bootloader.nix
    ./hardware.nix
    ./keyd.nix
    ./xserver.nix
    ./network.nix
    ./nh.nix
    ./pipewire.nix
    ./program.nix
    ./security.nix
    ./services.nix
    ./steam.nix
    ./system.nix
    ./flatpak.nix
    ./stylix.nix
    ./user.nix
    ./wayland.nix
    ./virtualization.nix
  ];
}
