{ lib
, pkgs
, callPackage
, writeShellScriptBin
, writeText
, removeReferencesTo
, linuxPackagesFor
, _4KBuild ? false
, withRust ? false
, _kernelPatches ? [ ]
}:

let
  parseExtraConfig = cfg: let
    lines = builtins.filter (s: s != "") (lib.strings.splitString "\n" cfg);
    perLine = line: let
      kv = lib.strings.splitString " " line;
    in assert (builtins.length kv == 2);
       "CONFIG_${builtins.elemAt kv 0}=${builtins.elemAt kv 1}";
    in lib.strings.concatMapStringsSep "\n" perLine lines;

  parseConfig = config:
    let
      parseLine = builtins.match "(CONFIG_[[:upper:][:digit:]_]+)=(y|m|n)";
      lines = lib.strings.splitString "\n" config;
      pairs = builtins.filter (x: x != null) (map parseLine lines);
    in
    builtins.listToAttrs (map
      (pair: lib.nameValuePair
        (builtins.elemAt pair 0)
        (builtins.elemAt pair 1))
      pairs);
  readConfig = configfile: parseConfig (builtins.readFile configfile);

  linux-asahi-pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, linuxKernel,
      rustPlatform, rustc, rustfmt, rust-bindgen, ... } @ args:
    let
      configfile = if _kernelPatches == [ ] then ./config else
        writeText "config" ''
          ${builtins.readFile ./config}

          # Patches
          ${lib.strings.concatMapStringsSep "\n" ({extraConfig ? "", ...}: parseExtraConfig extraConfig) _kernelPatches}
        '';

      # used to (ostensibly) keep compatibility for those running stable versions of nixos
      rustOlder = version: withRust && (lib.versionOlder rustc.version version);
      bindgenOlder = version: withRust && (lib.versionOlder rust-bindgen.unwrapped.version version);

      # used to fix issues when nixpkgs gets ahead of the kernel
      rustAtLeast = version: withRust && (lib.versionAtLeast rustc.version version);
      bindgenAtLeast = version: withRust && (lib.versionAtLeast rust-bindgen.unwrapped.version version);
    in
    (linuxKernel.manualConfig rec {
      inherit stdenv lib;

      version = "6.3.0-asahi";
      modDirVersion = version;

      src = fetchFromGitHub {
        # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/linux-asahi/PKGBUILD
        owner = "AsahiLinux";
        repo = "linux";
        rev = "asahi-6.3-8";
        hash = "sha256-/5dD5QidvQo9bwqDnkVtxF9Kj3WMS0uqqIcn8MPyao8=";
      };

      kernelPatches = [
        { name = "rust-bindgen-version";
          patch = ./rust-bindgen-version.patch;
        }
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
          patch = ./rust-bindgen-0.63-fix.patch;
        }
      ] ++ lib.optionals (bindgenAtLeast "0.65.0") [
        { name = "rust-bindgen";
          patch = ./rust-bindgen-0.65-fix.patch;
        }
      ] ++ lib.optionals (rustOlder "1.67.0") [
        { name = "rust-1.67.0";
          patch = ./rust_1_67_0.patch;
          reverse = true;
        }
      ] ++ lib.optionals (rustAtLeast "1.70.0") [
        { name = "rust-1.70.0";
          patch = pkgs.fetchpatch {
            name = "rust-1.70.patch";
            url = "https://github.com/AsahiLinux/linux/commit/496a1b061691f01602aa63d2a8027cf3020d4bb8.diff";
            hash = "sha256-RxOzCE22+yfZ3r/1sjbP8Cp+rRa56SJjHjwjTJxfIUI=";
          };
        }
      ] ++ _kernelPatches;

      inherit configfile;
      config = readConfig configfile;

      extraMeta.branch = "6.2";
    } // (args.argsOverride or {})).overrideAttrs (old: if withRust then {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
        rust-bindgen
        rustfmt
        rustc
        removeReferencesTo
      ];
      # HACK: references shouldn't have been there in the first place
      postFixup = (old.postFixup or "") + ''
        remove-references-to -t $out $dev/lib/modules/${old.version}/build/vmlinux
        remove-references-to -t $dev $out/Image
      '';
      RUST_LIB_SRC = rustPlatform.rustLibSrc;
    } else {});

  linux-asahi = (callPackage linux-asahi-pkg { });
in lib.recurseIntoAttrs (linuxPackagesFor linux-asahi)

