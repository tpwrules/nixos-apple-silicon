{
  description = "Apple Silicon support for NixOS";

  inputs = {
    nixpkgs = {
      # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
      # these evals have a cross-compiled stdenv available
      url = "github:nixos/nixpkgs/6df37dc6a77654682fe9f071c62b4242b5342e04";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      flake = false;
    };

    flake-compat.url = "github:nix-community/flake-compat";
  };

  outputs = { self, ... }@inputs:
    let
      # build platforms supported for uboot in nixpkgs
      systems = [ "aarch64-linux" "x86_64-linux" ]; # "i686-linux" omitted

      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
    in
      {
        overlays = rec {
          apple-silicon-overlay = import ./apple-silicon-support/packages/overlay.nix;
          default = apple-silicon-overlay;
        };

        nixosModules = rec {
          apple-silicon-support = ./apple-silicon-support;
          default = apple-silicon-support;
        };

        packages = forAllSystems (system:
          let
            pkgs = import inputs.nixpkgs {
              crossSystem.system = "aarch64-linux";
              localSystem.system = system;
              overlays = [
                (import inputs.rust-overlay)
                self.overlays.default
              ];
            };
          in {
            inherit (pkgs) m1n1 uboot-asahi linux-asahi asahi-fwextract mesa-asahi-edge;
            inherit (pkgs) speakersafetyd bankstown-lv2 asahi-audio;

            installer-bootstrap =
              let
                installer-system = inputs.nixpkgs.lib.nixosSystem {
                  inherit system;

                  # make sure this matches the post-install
                  # `hardware.asahi.pkgsSystem`
                  pkgs = import inputs.nixpkgs {
                    crossSystem.system = "aarch64-linux";
                    localSystem.system = system;
                    overlays = [ self.overlays.default ];
                  };

                  specialArgs = {
                    modulesPath = inputs.nixpkgs + "/nixos/modules";
                  };

                  modules = [
                    ./iso-configuration
                    { hardware.asahi.pkgsSystem = system; }
                  ];
                };

                config = installer-system.config;
              in (config.system.build.isoImage.overrideAttrs (old: {
                # add ability to access the whole config from the command line
                passthru = (old.passthru or {}) // { inherit config; };
              }));
          });
      };
}
