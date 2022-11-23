{ pkgs, _4KBuild ? false }:
let
  localPkgs =
    # we do this so the config can be read on any system and not affect
    # the output hash
    if builtins ? currentSystem then import (pkgs.path) { system = builtins.currentSystem; }
    else pkgs;

  readConfig = configfile: import (localPkgs.runCommand "config.nix" { } ''
    echo "{" > "$out"
    while IFS='=' read key val; do
      [ "x''${key#CONFIG_}" != "x$key" ] || continue
      no_firstquote="''${val#\"}";
      echo '  "'"$key"'" = "'"''${no_firstquote%\"}"'";' >> "$out"
    done < "${configfile}"
    echo "}" >> $out
  '').outPath;

  linux_asahi_pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, linuxKernel, ... } @ args:
    linuxKernel.manualConfig
      rec {
        inherit stdenv lib;

        version = "6.1.0-rc6-asahi";
        modDirVersion = version;

        src = fetchFromGitHub {
          # tracking branch: https://github.com/AsahiLinux/linux/tree/asahi
          owner = "AsahiLinux";
          repo = "linux";
          rev = "asahi-6.1-rc6-5";
          hash = "sha256-HHPfAtNh5wR0TCsEYuMdSbp55p1IVhF07tg4dlfgXk0=";
        };

        kernelPatches = [
        ] ++ lib.optionals _4KBuild [
          # thanks to Sven Peter
          # https://lore.kernel.org/linux-iommu/20211019163737.46269-1-sven@svenpeter.dev/
          {
            name = "sven-iommu-4k";
            patch = ./sven-iommu-4k.patch;
          }
        ] ++ lib.optionals (!_4KBuild) [
          # patch the kernel to set the default size to 16k instead of modifying
          # the config so we don't need to convert our config to the nixos
          # infrastructure or patch it and thus introduce a dependency on the host
          # system architecture
          {
            name = "default-pagesize-16k";
            patch = ./default-pagesize-16k.patch;
          }
        ];

        configfile = ./config;
        config = readConfig configfile;

        extraMeta.branch = "6.1";
      } // (args.argsOverride or { });

  linux_asahi = (pkgs.callPackage linux_asahi_pkg { });
in
pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_asahi)

