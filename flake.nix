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
          overlays = rec {
            asahi-overlay = import packages/overlay.nix;
            default = asahi-overlay;
          };

          nixosModules = rec {
            m1-support = ./nixos-module;
            default = m1-support;
          };
        };

        # build platforms supported for uboot in nixpkgs
        systems = [ "aarch64-linux" "x86_64-linux" "i686-linux" ];

        perSystem = { system, pkgs, ... }: {
          # override the `pkgs` argument used by flake-parts modules
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.rust-overlay.overlays.default
              self.overlays.default
            ];
          };

          packages = {
            inherit (pkgs) m1n1 uboot-asahi;

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
