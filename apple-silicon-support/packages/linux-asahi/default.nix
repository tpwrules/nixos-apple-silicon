{ lib
, pkgs
, callPackage
, writeShellScriptBin
, writeText
, linuxPackagesFor
, _4KBuild ? false
, withRust ? false
, kernelPatches ? [ ]
}:

let
  # TODO: use a pure nix regex parser instead of an IFD, and remove this workaround
  localPkgs = if builtins ? currentSystem
    then import (pkgs.path) {
      crossSystem.system = builtins.currentSystem;
      localSystem.system = builtins.currentSystem;
    }
    else pkgs;

  inherit (localPkgs) runCommand;

  parseExtraConfig = cfg: let
    lines = builtins.filter (s: s != "") (lib.strings.splitString "\n" cfg);
    perLine = line: let
      kv = lib.strings.splitString " " line;
    in assert (builtins.length kv == 2);
       "CONFIG_${builtins.elemAt kv 0}=${builtins.elemAt kv 1}";
    in lib.strings.concatMapStringsSep "\n" perLine lines;

  readConfig = configfile: import (runCommand "config.nix" { } ''
    echo "{ } // " > "$out"
    while IFS='=' read key val; do
      [ "x''${key#CONFIG_}" != "x$key" ] || continue
      no_firstquote="''${val#\"}";
      echo '{  "'"$key"'" = "'"''${no_firstquote%\"}"'"; } //' >> "$out"
    done < "${configfile}"
    echo "{ }" >> $out
  '').outPath;

  linux-asahi-pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, linuxKernel,
      rustPlatform, rustfmt, rust-bindgen, ... } @ args:
    let
      configfile = if kernelPatches == [ ] then ./config else
        writeText "config" ''
          ${builtins.readFile ./config}

          # Patches
          ${lib.strings.concatMapStringsSep "\n" ({extraConfig ? "", ...}: parseExtraConfig extraConfig) kernelPatches}
        '';

      _kernelPatches = kernelPatches;

      # used to (ostensibly) keep compatibility for those running stable versions of nixos
      rustOlder = version: withRust && (lib.versionOlder rustPlatform.rust.rustc.version version);
      bindgenOlder = version: withRust && (lib.versionOlder rustPlatform.rust.rustc.version version);

      # used to fix issues when nixpkgs gets ahead of the kernel
      rustAtLeast = version: withRust && (lib.versionAtLeast rustPlatform.rust.rustc.version version);
      bindgenAtLeast = version: withRust && (lib.versionAtLeast rust-bindgen.unwrapped.version version);
    in
    (linuxKernel.manualConfig rec {
      inherit stdenv lib;

      version = "6.2.0-asahi";
      modDirVersion = version;

      src = fetchFromGitHub {
        # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/linux-asahi/PKGBUILD
        owner = "AsahiLinux";
        repo = "linux";
        rev = "asahi-6.2-11";
        hash = "sha256-5ns8ilv+Kee2BHhpWm7CnNHf3+mcXCywkLhx4oh9rZk=";
      };

      kernelPatches = [
      ] ++ lib.optionals _4KBuild [
        # thanks to Sven Peter
        # https://lore.kernel.org/linux-iommu/20211019163737.46269-1-sven@svenpeter.dev/
        { name = "sven-iommu-4k";
          patch = ./sven-iommu-4k.patch;
        }
        (builtins.throw "The Asahi 4K kernel patch is currently broken. Contributions to fix are welcome.")
      ] ++ lib.optionals (!_4KBuild) [
        # patch the kernel to set the default size to 16k instead of modifying
        # the config so we don't need to convert our config to the nixos
        # infrastructure or patch it and thus introduce a dependency on the host
        # system architecture
        { name = "default-pagesize-16k";
          patch = ./default-pagesize-16k.patch;
        }
      ] ++ lib.optionals (rustOlder "1.66.0") [
        { name = "rust-1.66.0";
          patch = ./rust_1_66_0.patch;
          reverse = true;
        }
      ] ++ lib.optionals (bindgenAtLeast "0.63.0") [
        { name = "rust-bindgen";
          patch = ./rust-bindgen-fix.patch;
        }
      ] ++ lib.optionals (rustOlder "1.67.0") [
        { name = "rust-1.67.0";
          patch = ./rust_1_67_0.patch;
          reverse = true;
        }
      ] ++ _kernelPatches;

      inherit configfile;
      config = readConfig configfile;

      extraMeta.branch = "6.2";
    } // (args.argsOverride or {})).overrideAttrs (old: if withRust then {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
        rust-bindgen
        rustfmt
        rustPlatform.rust.rustc
      ];
      RUST_LIB_SRC = rustPlatform.rustLibSrc;
    } else {});

  linux-asahi = (callPackage linux-asahi-pkg { });
in lib.recurseIntoAttrs (linuxPackagesFor linux-asahi)

