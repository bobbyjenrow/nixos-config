{ pkgs, lib, ... }:
let
  theme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
  wallpaper = pkgs.runCommand "../../wallpapers/wallpaper.png" { } ''
    COLOR=$(${lib.getExe pkgs.yq} -r .palette.base00 ${theme})
    ${lib.getExe pkgs.imagemagick} -size 1920x1080 xc:$COLOR $out
  '';
in
{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    image = wallpaper;
    base16Scheme = theme;
    opacity = {
      terminal = 0.66;
    };
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      # monospace = {
      #   package = pkgs.dejavu_fonts;
      #   name = "DejaVu Sans Mono";
      # };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
