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
        systems = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];

        flake = {
          overlays.default = import packages/overlay.nix;

          # TODO: make the nixos module use our overlay
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

        perSystem = { system, pkgs, ... }: {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.rust-overlay.overlays.default
              self.overlays.default
            ];
          };

          packages = {
            # exposing installer-config breaks `nix flake show`
            # https://github.com/NixOS/nix/issues/4265
            installer-bootstrap =
              let installer-config = import ./installer-bootstrap { inherit pkgs; };
              in installer-config.system.build.isoImage;
          };
        };
      }
    );
}
