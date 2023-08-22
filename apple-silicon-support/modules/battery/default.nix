{ config, lib, ... }:
{
  config = let
    cfg = config.services.asahi-battery-threshold;
    pkgs' = config.hardware.asahi.pkgs;
  in {
    environment.etc."asahi-battery-threshold.conf".text = ''
      start_charging_threshold = ${toString cfg.startCharging}
      stop_charging_threshold = ${toString cfg.stopCharging}
    '';

    systemd.services.asahi-battery-threshold = {
      description = "asahi-battery-threshold";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = lib.getExe pkgs'.asahi-battery-threshold;
        ExecStop = "echo auto > /sys/class/power_supply/macsmc-battery/charge_behaviour";
      };
    };
  };

  options.services.asahi-battery-threshold.enable = lib.mkEnableOption "asahi-battery-threshold, a daemon to manage charging thresholds";

  options.services.asahi-battery-threshold.startCharging = lib.mkOption {
    type = lib.types.ints.between 0 100;
    default = 80;
    description = ''
      Battery percentage at which to start charging.
    '';
  };

  options.services.asahi-battery-threshold.stopCharging = lib.mkOption {
    type = lib.types.ints.between 0 100;
    default = 85;
    description = ''
      Battery percentage at which to stop charging.
    '';
  };
}
