{
  description = "Wojtek's dotfiles - nix-darwin and NixOS multi-host configuration";

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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "git+https://github.com/wojtodzio/nix-secrets.git";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      darwin,
      home-manager,
      determinate,
      agenix,
      nix-index-database,
      nix-secrets,
      ...
    }:
    let
      # Overlays for both systems
      overlays = [
        # Unstable packages overlay
        (final: prev: {
          unstable = import nixpkgs-unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        })
      ]
      ++ (import ./overlays);
    in
    {
      # macOS configuration
      darwinConfigurations.macbook = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          determinate.darwinModules.default
          { nixpkgs.overlays = overlays; }
          home-manager.darwinModules.home-manager
          agenix.darwinModules.default
          ./hosts/macbook/default.nix
          { nix.registry.nixpkgs.flake = nixpkgs; }
        ];
        specialArgs = {
          inherit (nixpkgs) lib;
          inherit nix-index-database;
        };
      };

      # NixOS configuration
      nixosConfigurations.posejdon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          determinate.nixosModules.default
          { nixpkgs.overlays = overlays; }
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          ./hosts/posejdon/default.nix
          { nix.registry.nixpkgs.flake = nixpkgs; }
        ];
        specialArgs = {
          inherit (nixpkgs) lib;
          inherit nix-index-database;
          nixSecrets = nix-secrets;
        };
      };

      # Convenience aliases
      darwinConfigurations.Wojciechs-MacBook-Pro = self.darwinConfigurations.macbook;
    };
}
