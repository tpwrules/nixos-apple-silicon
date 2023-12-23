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
  i = builtins.elemAt;

  # parse <OPT> [ymn]|foo style configuration as found in a patch's extraConfig
  # into a list of k, v tuples
  parseExtraConfig = config:
    let
      lines =
        builtins.filter (s: s != "") (lib.strings.splitString "\n" config);
      parseLine = line: let
        t = lib.strings.splitString " " line;
        join = l: builtins.foldl' (a: b: "${a} ${b}")
          (builtins.head l) (builtins.tail l);
        v = if (builtins.length t) > 2 then join (builtins.tail t) else (i t 1);
      in [ "CONFIG_${i t 0}" v ];
    in map parseLine lines;

  # parse <OPT>=lib.kernel.(yes|module|no)|lib.kernel.freeform "foo"
  # style configuration as found in a patch's extraStructuredConfig into
  # a list of k, v tuples
  parseExtraStructuredConfig = config: lib.attrsets.mapAttrsToList
    (k: v: [ "CONFIG_${k}" (v.tristate or v.freeform) ] ) config;

  parsePatchConfig = { extraConfig ? "", extraStructuredConfig ? {}, ... }:
    (parseExtraConfig extraConfig) ++
    (parseExtraStructuredConfig extraStructuredConfig);

  # parse CONFIG_<OPT>=[ymn]|"foo" style configuration as found in a config file
  # into a list of k, v tuples
  parseConfig = config:
    let
      parseLine = builtins.match ''(CONFIG_[[:upper:][:digit:]_]+)=(([ymn])|"([^"]*)")'';
      # get either the [ymn] option or the "foo" option; whichever matched
      t = l: let v = (i l 2); in [ (i l 0) (if v != null then v else (i l 3)) ];
      lines = lib.strings.splitString "\n" config;
    in map t (builtins.filter (l: l != null) (map parseLine lines));

  origConfigfile = ./config;

  linux-asahi-pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, linuxKernel,
      rustPlatform, rustc, rustfmt, rust-bindgen, ... } @ args:
    let
      origConfigText = builtins.readFile origConfigfile;

      # extraConfig from all patches in order
      extraConfig =
        lib.fold (patch: ex: ex ++ (parsePatchConfig patch)) [] _kernelPatches;
      # config file text for above
      extraConfigText = let
        text = k: v: if (v == "y") || (v == "m") || (v == "n")
          then "${k}=${v}" else ''${k}="${v}"'';
      in (map (t: text (i t 0) (i t 1)) extraConfig);

      # final config as a text file path
      configfile = if extraConfig == [] then origConfigfile else
        writeText "config" ''
          ${origConfigText}

          # Patches
          ${lib.strings.concatStringsSep "\n" extraConfigText}
        '';
      # final config as an attrset
      config = let
        makePair = t: lib.nameValuePair (i t 0) (i t 1);
        configList = (parseConfig origConfigText) ++ extraConfig;
      in builtins.listToAttrs (map makePair (lib.lists.reverseList configList));

      # used to (ostensibly) keep compatibility for those running stable versions of nixos
      rustOlder = version: withRust && (lib.versionOlder rustc.version version);
      bindgenOlder = version: withRust && (lib.versionOlder rust-bindgen.unwrapped.version version);

      # used to fix issues when nixpkgs gets ahead of the kernel
      rustAtLeast = version: withRust && (lib.versionAtLeast rustc.version version);
      bindgenAtLeast = version: withRust && (lib.versionAtLeast rust-bindgen.unwrapped.version version);
    in
    (linuxKernel.manualConfig rec {
      inherit stdenv lib;

      version = "6.6.0-asahi";
      modDirVersion = version;
      extraMeta.branch = "6.6";

      src = fetchFromGitHub {
        # tracking: https://github.com/AsahiLinux/linux/tree/asahi-wip (w/ fedora verification)
        owner = "AsahiLinux";
        repo = "linux";
        rev = "asahi-6.6-14";
        hash = "sha256-+ydX2XXIbcVfq27WC68EPP8n3bf+WD5fDG7FBq3QJi4=";
      };

      kernelPatches = [
        # speaker enablement; we assert on the relevant lsp-plugins patch
        # before installing speakersafetyd to let the speakers work
        { name = "speakers-1";
          patch = fetchpatch {
            url = "https://github.com/AsahiLinux/linux/commit/385ea7b5023486aba7919cec8b6b3f6a843a1013.patch";
            hash = "sha256-u7IzhJbUgBPfhJXAcpHw1I6OPzPHc1UKYjH91Ep3QHQ=";
          };
        }
        { name = "speakers-2";
          patch = fetchpatch {
            url = "https://github.com/AsahiLinux/linux/commit/6a24102c06c95951ab992e2d41336cc6d4bfdf23.patch";
            hash = "sha256-wn5x2hN42/kCp/XHBvLWeNLfwlOBB+T6UeeMt2tSg3o=";
          };
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
      ] ++ _kernelPatches;

      inherit configfile config;
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

