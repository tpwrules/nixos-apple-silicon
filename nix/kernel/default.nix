{ pkgs, nativeBuild ? false }: let
  buildPkgs = if nativeBuild then
    import (pkgs.path) {
      system = "aarch64-linux";
    }
  else (
    import (pkgs.path) {
      system = "x86_64-linux";
      crossSystem.system = "aarch64-linux";
    }
  );

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

  linux_asahi_pkg = { stdenv, lib, fetchFromGitHub, linuxKernel, ... } @ args:
    linuxKernel.manualConfig rec {
      inherit stdenv lib;

      version = "5.16.0-rc5-asahi-next-20211214";
      modDirVersion = version;

      src = fetchFromGitHub {
        # TO MODIFY THE KERNEL CONFIG: modify it, then run
        # $ sudo nixos-rebuild boot
        # and reboot.

        # TO UPDATE THE KERNEL SOURCES: set the Git repo information here
        owner = "AsahiLinux";
        repo = "linux";
        rev = "b63c1083b20eefa3b23180ae57e1919c723f7d86";
        # then, set hash = lib.fakeHash; (with no quotes)
        hash = "sha256-g9pzjkEhSYXILzNCyrH9qWge+H+3gpbnnNwY7xH/beo=";
        # Run `sudo nixos-rebuild boot`.
        # Nix will download and hash the source, then tell you something like:
        #  error: hash mismatch in fixed-output derivation
        #   specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
        #      got:    sha256-g9pzjkEhSYXILzNCyrH9qWge+H+3gpbnnNwY7xH/beo=
        # now, set hash = "<that value>"; and run the rebuild command again.
      };

      configfile = ./config;
      config = readConfig configfile;

      extraMeta.branch = "5.16";
    } // (args.argsOverride or {});

  linux_asahi = buildPkgs.callPackage linux_asahi_pkg { };
in buildPkgs.recurseIntoAttrs (buildPkgs.linuxPackagesFor linux_asahi)
