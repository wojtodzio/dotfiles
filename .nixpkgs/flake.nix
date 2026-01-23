{
  description = "Wojtek's dotfiles - nix-darwin and home-manager configuration";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2511";
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

    darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2511";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.2511";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      darwin,
      home-manager,
      determinate,
      ...
    }:
    let
      system = "aarch64-darwin";

      overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
    in
    {
      darwinConfigurations = {
        Wojciechs-MacBook-Pro = darwin.lib.darwinSystem {
          inherit system;

          modules = [
            determinate.darwinModules.default

            {
              nixpkgs.overlays = overlays;
            }

            home-manager.darwinModules.home-manager

            ./darwin-configuration.nix

            {
              nix.registry.nixpkgs.flake = nixpkgs;
            }
          ];

          specialArgs = {
            inherit (nixpkgs) lib;
          };
        };

        macbook = self.darwinConfigurations.Wojciechs-MacBook-Pro;
      };

      darwinPackages = self.darwinConfigurations.Wojciechs-MacBook-Pro.pkgs;
    };
}
