{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libation
  ];
}
