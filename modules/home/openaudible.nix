{ pkgs, ... }:
{
  home.packages = with pkgs; [
    openaudible
  ];
}
