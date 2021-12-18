{ pkgs }: let
  linux_asahi_pkg = { stdenv, lib, fetchFromGitHub, linuxKernel, ... } @ args:
    linuxKernel.manualConfig rec {
      inherit stdenv lib;

      version = "5.16.0-rc5-asahi-next-20211214";
      modDirVersion = version;

      src = fetchFromGitHub {
        owner = "AsahiLinux";
        repo = "linux";
        rev = "b63c1083b20eefa3b23180ae57e1919c723f7d86";
        hash = "sha256-g9pzjkEhSYXILzNCyrH9qWge+H+3gpbnnNwY7xH/beo=";
      };

      configfile = ./config;
      allowImportFromDerivation = true;

      kernelPatches = [
        { name = "sorry"; patch = ./0001-horrendous-nvme-hack.patch; }
      ];

      extraMeta.branch = "5.16";
    } // (args.argsOverride or {});

  linux_asahi = pkgs.callPackage linux_asahi_pkg {};
in pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_asahi)
