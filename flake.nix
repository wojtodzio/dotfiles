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

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "darwin";
      inputs.home-manager.follows = "home-manager";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "git+https://github.com/wojtodzio/nix-secrets.git";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
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
        (final: _prev: {
          unstable = import nixpkgs-unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        })
      ]
      ++ (import ./overlays);
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          # Formatter for `nix fmt`
          formatter = pkgs.nixfmt-rfc-style;

          # Development shell with linting tools
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
              nixfmt-tree
              statix
              deadnix
              pre-commit
            ];
          };

          # Checks for CI
          checks = {
            statix =
              pkgs.runCommand "statix-check"
                {
                  buildInputs = [ pkgs.statix ];
                  src = self;
                }
                ''
                  cd $src
                  statix check .
                  touch $out
                '';
            deadnix =
              pkgs.runCommand "deadnix-check"
                {
                  buildInputs = [ pkgs.deadnix ];
                  src = self;
                }
                ''
                  cd $src
                  deadnix --fail -L .
                  touch $out
                '';
          };

          # Apps for common workflows
          apps = {
            check = {
              type = "app";
              meta.description = "Run nix flake check";
              program = toString (
                pkgs.writeShellScript "check" ''
                  ${pkgs.nix}/bin/nix flake check
                ''
              );
            };

            fmt = {
              type = "app";
              meta.description = "Format the flake with nix fmt";
              program = toString (
                pkgs.writeShellScript "fmt" ''
                  ${pkgs.nixfmt-tree}/bin/nixfmt-tree .
                ''
              );
            };

            update = {
              type = "app";
              meta.description = "Update flake inputs";
              program = toString (
                pkgs.writeShellScript "update" ''
                  ${pkgs.nix}/bin/nix flake update
                ''
              );
            };

            build-macbook = {
              type = "app";
              meta.description = "Build the macbook configuration";
              program = toString (
                pkgs.writeShellScript "build-macbook" ''
                  if [ "$(uname)" != "Darwin" ]; then
                    echo "Error: build-macbook must run on macOS"
                    exit 1
                  fi
                  ${pkgs.nix}/bin/nix build .#darwinConfigurations.macbook.system
                ''
              );
            };

            build-posejdon = {
              type = "app";
              meta.description = "Build the posejdon configuration";
              program = toString (
                pkgs.writeShellScript "build-posejdon" ''
                  ${pkgs.nix}/bin/nix build .#nixosConfigurations.posejdon.config.system.build.toplevel
                ''
              );
            };

            switch-macbook = {
              type = "app";
              meta.description = "Switch macbook to latest configuration";
              program = toString (
                pkgs.writeShellScript "switch-macbook" ''
                  if [ "$(uname)" != "Darwin" ]; then
                    echo "Error: switch-macbook must run on macOS"
                    exit 1
                  fi
                  darwin-rebuild switch --flake .#macbook
                ''
              );
            };

            switch-posejdon = {
              type = "app";
              meta.description = "Switch posejdon to latest configuration";
              program = toString (
                pkgs.writeShellScript "switch-posejdon" ''
                  if [ "$(uname)" = "Darwin" ]; then
                    echo "Error: switch-posejdon must run on Linux (posejdon)"
                    exit 1
                  fi
                  sudo nixos-rebuild switch --flake .#posejdon
                ''
              );
            };
          };
        };

      flake = {
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
    };
}
