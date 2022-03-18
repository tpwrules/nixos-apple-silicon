{ pkgs, crossBuild ? false, _16KBuild ? false }: let
  buildPkgs = if crossBuild then
    import (pkgs.path) {
      system = "x86_64-linux";
      crossSystem.system = "aarch64-linux";
    }
  else pkgs;

  # we do this so the config can be read on any system and not affect
  # the output hash
  localPkgs = import (pkgs.path) { system = builtins.currentSystem; };
  readConfig = configfile: import (localPkgs.runCommand "config.nix" {} ''
    echo "{" > "$out"
    while IFS='=' read key val; do
      [ "x''${key#CONFIG_}" != "x$key" ] || continue
      no_firstquote="''${val#\"}";
      echo '  "'"$key"'" = "'"''${no_firstquote%\"}"'";' >> "$out"
    done < "${configfile}"
    echo "}" >> $out
  '').outPath;

  linux_asahi_pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, linuxKernel, ... } @ args:
    linuxKernel.manualConfig rec {
      inherit stdenv lib;

      version = "5.17.0-rc7-asahi-next-20220310";
      modDirVersion = version;

      src = fetchFromGitHub {
        # tracking branch: https://github.com/AsahiLinux/linux/tree/asahi
        owner = "AsahiLinux";
        repo = "linux";
        rev = "00e23945f258f06ed0cb0dd9ea44272cbdfc7346";
        hash = "sha256-oHEy0QS7RkhR9Av68rqAAmR8kXi0ZR4yot0uGWfJOzw=";
      };

      kernelPatches = [
      ] ++ lib.optionals (!_16KBuild) [
        # thanks to Sven Peter
        # https://lore.kernel.org/linux-iommu/20211019163737.46269-1-sven@svenpeter.dev/
        { name = "sven-iommu-4k";
          patch = ./sven-iommu-4k.patch;
        }
      ] ++ lib.optionals _16KBuild [
        # patch the kernel to set the default size to 16k so we don't need to
        # convert our config to the nixos infrastructure or patch it and thus
        # introduce a dependency on the host system architecture
        { name = "default-pagesize-16k";
          patch = ./default-pagesize-16k.patch;
        }
      ];

      configfile = ./config;
      config = readConfig configfile;

      extraMeta.branch = "5.17";
    } // (args.argsOverride or {});

  linux_asahi = buildPkgs.callPackage linux_asahi_pkg { };
in buildPkgs.recurseIntoAttrs (buildPkgs.linuxPackagesFor linux_asahi)
