{
  description = "Apple M1 support for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }: {
        flake = {
          overlays.default = import packages/overlay.nix;

          nixosModules = rec {
            m1-support = ./nixos-module;
            default = m1-support;
          };

          packages.aarch64-linux = withSystem "aarch64-linux" (
            { pkgs, ... }: {
              inherit (pkgs) m1n1 u-boot asahi-fwextract;
            }
          );
        };

        # all nixpkgs systems
        systems = inputs.nixpkgs.lib.systems.flakeExposed;

        perSystem = { system, pkgs, ... }: {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.rust-overlay.overlays.default
              self.overlays.default
            ];
          };

          packages = {
            installer-bootstrap =
              let
                installer-system = inputs.nixpkgs.lib.nixosSystem {
                  specialArgs = { modulesPath = inputs.nixpkgs + "/nixos/modules"; };
                  modules = [
                    ./iso-configuration
                    {
                      nixpkgs.crossSystem.system = "aarch64-linux";
                      nixpkgs.localSystem.system = system;
                      hardware.asahi.pkgsSystem = system;
                    }
                  ];
                };
              in installer-system.config.system.build.isoImage;
          };
        };
      }
    );
}
