{ pkgs }: let
  linux_asahi_pkg = { lib, fetchFromGitHub, buildLinux, ... } @ args:
    buildLinux (args // rec {
      version = "5.16.0-rc4-asahi-next-20211206";
      modDirVersion = version;

      src = fetchFromGitHub {
        owner = "AsahiLinux";
        repo = "linux";
        rev = "87ff02b4daceca098e84f514a19a2baa6a030bca";
        hash = "sha256-+sajNpL9oeTAtCu58UYiiAldJrVdpVbHTYeDL1DkPj8=";
      };
      kernelPatches = [];

      baseConfig = "defconfig";
      extraConfig = ''
        FB_SIMPLE y
      '';
      target = "zImage";

      extraMeta.branch = "5.16";
    } // (args.argsOverride or {}));

  linux_asahi = pkgs.callPackage linux_asahi_pkg {};
in pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_asahi)
