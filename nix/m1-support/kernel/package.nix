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
        # TO MODIFY THE KERNEL CONFIG: modify the ./config file, then run
        # $ sudo nixos-rebuild boot
        # and reboot.

        # TO UPDATE THE KERNEL SOURCES: set the Git repo information here
        owner = "AsahiLinux";
        repo = "linux";
        rev = "c1fcb91bbcc8fd1b1f874e45f55cbba682351f3c";
        # then, set hash = lib.fakeHash; (with no quotes)
        hash = "sha256-UTv1gGQqENMqBQ5j5nPYzaifxv7f49dTHH4O0SG3FhI=";
        # Run `sudo nixos-rebuild boot`.
        # Nix will download and hash the source, then tell you something like:
        #  error: hash mismatch in fixed-output derivation
        #   specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
        #      got:    sha256-g9pzjkEhSYXILzNCyrH9qWge+H+3gpbnnNwY7xH/beo=
        # now, set hash = "<that value>"; and run the rebuild command again.
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
