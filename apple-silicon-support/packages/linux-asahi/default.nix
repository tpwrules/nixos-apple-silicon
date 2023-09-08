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
  # parse <OPT> (y|m|n) style configuration as found in a patch's extraConfig
  # into a list of k, v tuples
  parseExtraConfig = config:
    let
      lines =
        builtins.filter (s: s != "") (lib.strings.splitString "\n" config);
      parseLine = line:
        let t = lib.strings.splitString " " line;
        in assert (builtins.length t == 2); t;
    in map parseLine lines;

  # parse CONFIG_<OPT>=(y|m|n) style configuration as found in a config file
  # into a list of k, v tuples
  parseConfig = config:
    let
      parseLine = builtins.match "(CONFIG_[[:upper:][:digit:]_]+)=(y|m|n)";
      lines = lib.strings.splitString "\n" config;
    in builtins.filter (t: t != null) (map parseLine lines);

  origConfigfile = ./config;

  linux-asahi-pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, linuxKernel,
      rustPlatform, rustc, rustfmt, rust-bindgen, ... } @ args:
    let
      origConfigText = builtins.readFile origConfigfile;

      # extraConfig from all patches in order
      extraConfig = lib.fold (patch: ex: ex ++
        (parseExtraConfig (patch.extraConfig or ""))) [] _kernelPatches;
      # config file text for above
      extraConfigText = (map (t: "CONFIG_${builtins.elemAt t 0}=${builtins.elemAt t 1}") extraConfig);

      # final config as a text file path
      configfile = if extraConfig == [] then origConfigfile else
        writeText "config" ''
          ${origConfigText}

          # Patches
          ${lib.strings.concatStringsSep "\n" extraConfigText}
        '';
      # final config as an attrset
      config = let
        makePair = t: lib.nameValuePair (builtins.elemAt t 0) (builtins.elemAt t 1);
        configList = (parseConfig origConfigText) ++ extraConfig;
      in builtins.listToAttrs (map makePair configList);

      # used to (ostensibly) keep compatibility for those running stable versions of nixos
      rustOlder = version: withRust && (lib.versionOlder rustc.version version);
      bindgenOlder = version: withRust && (lib.versionOlder rust-bindgen.unwrapped.version version);

      # used to fix issues when nixpkgs gets ahead of the kernel
      rustAtLeast = version: withRust && (lib.versionAtLeast rustc.version version);
      bindgenAtLeast = version: withRust && (lib.versionAtLeast rust-bindgen.unwrapped.version version);
    in
    (linuxKernel.manualConfig rec {
      inherit stdenv lib;

      version = "6.4.0-asahi";
      modDirVersion = version;

      src = fetchFromGitHub {
        # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/linux-asahi/PKGBUILD
        owner = "AsahiLinux";
        repo = "linux";
        rev = "asahi-6.4-10";
        hash = "sha256-PUuQcqcQy7digMb0VwO5AVpAC8cA2WsTR6xDhGtL/pY=";
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
      ] ++ lib.optionals (bindgenAtLeast "0.63.0") [
        { name = "rust-bindgen";
          patch = ./rust-bindgen-0.63-fix.patch;
        }
      ] ++ lib.optionals (bindgenAtLeast "0.65.0") [
        { name = "rust-bindgen";
          patch = ./rust-bindgen-0.65-fix.patch;
        }
      ] ++ lib.optionals (rustAtLeast "1.72.0") [
        { name = "rustc-1.72.0";
          patch = ./rustc-1.72.0-fix.patch;
        }
      ] ++ _kernelPatches;

      inherit configfile config;

      extraMeta.branch = "6.4";
    } // (args.argsOverride or {})).overrideAttrs (old: if withRust then {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
        rust-bindgen
        rustfmt
        rustc
        removeReferencesTo
      ];
      # HACK: references shouldn't have been there in the first place
      # TODO: remove once 23.05 is obsolete
      postFixup = (old.postFixup or "") + ''
        if [ -f $dev/lib/modules/${old.version}/build/vmlinux ]; then
          remove-references-to -t $out $dev/lib/modules/${old.version}/build/vmlinux
        fi
        remove-references-to -t $dev $out/Image
      '';
      RUST_LIB_SRC = rustPlatform.rustLibSrc;
    } else {});

  linux-asahi = (callPackage linux-asahi-pkg { });
in lib.recurseIntoAttrs (linuxPackagesFor linux-asahi)

