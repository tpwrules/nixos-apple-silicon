{ pkgs }: let
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
      allowImportFromDerivation = true;

      extraMeta.branch = "5.16";
    } // (args.argsOverride or {});

  linux_asahi = pkgs.callPackage linux_asahi_pkg {};
in pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_asahi)
