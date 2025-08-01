{
  description = "bobbyjjenrow's nixos configuration based on FrostPhoenix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hypr-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs = {
        hyprgraphics.follows = "hyprland/hyprgraphics";
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

    nur.url = "github:nix-community/NUR";
    # nix-gaming.url = "github:fufexan/nix-gaming";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    zen-browser.url = "github:MarceColl/zen-browser-flake";

    ghostty.url = "github:ghostty-org/ghostty";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      self,
      stylix,
      home-manager,
      ...
    }@inputs:
    let
      username = "bobbyj";
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        # desktop = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     ./hosts/desktop
        #     stylix.nixosModules.stylix
        #   ];
        #   specialArgs = {
        #     host = "desktop";
        #     inherit self inputs username;
        #   };
        # };
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/laptop
            stylix.nixosModules.stylix
          ];
          specialArgs = {
            host = "laptop";
            input.keyd.laptopOnly = true;
            input.keyd.enable = true;
            inherit self inputs username;
          };

        };
        # vm = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [ ./hosts/vm ];
        #   specialArgs = {
        #     host = "vm";
        #     inherit self inputs username;
        #   };
        # };
      };

    };
}
