{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fuzzel
    bemoji
  ];
}
