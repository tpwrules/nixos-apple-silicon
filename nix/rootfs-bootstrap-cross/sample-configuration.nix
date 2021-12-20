# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible online at
# https://nixos.org/manual/nixos/stable/index.html#sec-installation).

{ config, pkgs, lib, ... }:

{
  # Enables the generation of /boot/extlinux/extlinux.conf
  # GRUB cannot correctly load device trees.
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Use the customized Asahi Linux kernel.
  # If you wish to modify the kernel, see /etc/nixos/kernel/default.nix.

  # IMPORTANT: if you have to build the kernel on the Mac itself, set
  # nativeBuild here to `true`. If you don't, Nix will complain that it
  # cannot find an x86_64-linux builder.
  boot.kernelPackages = pkgs.callPackage ./kernel { nativeBuild = false; };

  boot.consoleLogLevel = 7;
  boot.kernelParams = lib.mkForce [
    "earlycon"
    "console=ttySAC0,1500000"
    "console=tty0"
    "debug"
    "boot.shell_on_fail"
  ];

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Change this to the name of your interface, available via `ip addr`.
  # `enp3s0` is the internal interface on the Mac mini.
  networking.interfaces.enp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system and at least one desktop manager.
  # services.xserver.enable = true;
  # services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  #   firefox
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # nftables support is not yet in the kernel config
  networking.firewall.enable = false;

  # our kernel config is weird so don't try to include any modules
  boot.initrd.availableKernelModules = lib.mkForce [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

  swapDevices = [ ];

  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
