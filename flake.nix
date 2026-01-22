{
  description = "Wojtek's dotfiles - nix-darwin and home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      darwin,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";

      # Overlay to provide unstable packages
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
      darwinConfigurations.macbook = darwin.lib.darwinSystem {
        inherit system;

        modules = [
          {
            nixpkgs.overlays = overlays;
          }

          home-manager.darwinModules.home-manager

          ./.nixpkgs/darwin-configuration.nix
        ];

        specialArgs = {
          # This makes unstable available via <unstable> import in existing configs
          inherit (nixpkgs) lib;
        };
      };

      # Convenience for building
      darwinPackages = self.darwinConfigurations.macbook.pkgs;
    };
}
