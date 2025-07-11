{ inputs, pkgs, ... }:
{
  home.packages = (
    with pkgs; [
      inputs.zen-browser.packages."${system}".default
      firefox
      librewolf
      mullvad-browser
    ]
  );
  programs.firefox.profiles.bobbyj.extensions.packages = with pkgs; [
      nur.repos.rycee.firefox-addons.bitwarden
      nur.repos.rycee.firefox-addons.lastpass
  ];
}
