{
  config,
  lib,
  pkgs,
  ...
}:

let
  vpx = pkgs.callPackage ../pkgs/vpx.nix { };
in
{
  options.vpx = {
    enable = lib.mkEnableOption "VPX daemon (zray-core VPN manager)";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/vpx";
      description = "State/data directory used by vpxd (engine binaries, configs).";
    };
  };

  config = lib.mkIf config.vpx.enable {
    environment.systemPackages = [ vpx ];

    # vpxd creates /dev/net/tun; the shipped unit forbids CAP_SYS_MODULE, so the
    # module must be available without autoload.
    boot.kernelModules = [ "tun" ];

    systemd.services.vpxd = {
      description = "VPX Daemon (zray-core VPN manager)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      # vpxd shells out to these by bare name (ip route/nft/iptables/sysctl);
      # systemd's default PATH is /usr/{local/,}{s,}bin which on NixOS lacks them.
      path = with pkgs; [
        iproute2
        nftables
        iptables
        procps
      ];

      environment = {
        VPX_DATA_DIR = config.vpx.dataDir;
      };

      # Hardening mirrors the unit shipped inside the deb. vpxd runs as root by
      # necessity (rewrites /etc/resolv.conf, sets sysctls, drives ip/nft/
      # iptables, opens /dev/net/tun, reads /etc/shadow).
      serviceConfig = {
        ExecStart = "${vpx}/bin/vpxd";
        Restart = "on-failure";
        RestartSec = 5;

        NoNewPrivileges = true;
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        KeyringMode = "private";

        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_NET_BIND_SERVICE"
          "CAP_DAC_OVERRIDE"
          "CAP_DAC_READ_SEARCH"
          "CAP_CHOWN"
          "CAP_FOWNER"
          "CAP_KILL"
          "CAP_SETUID"
          "CAP_SETGID"
        ];
      };
    };

    # The four engine/data files are immutable; they live in the store and are
    # symlinked into the writable data dir (vpxd writes its own configs/state
    # alongside, not inside bin/).
    systemd.tmpfiles.rules =
      let
        d = config.vpx.dataDir;
      in
      [
        "d ${d} 0700 root root -"
        "d ${d}/bin 0700 root root -"
        "L+ ${d}/bin/zray-core - - - - ${vpx}/libexec/vpx/zray-core"
        "L+ ${d}/bin/zray-server - - - - ${vpx}/libexec/vpx/zray-server"
        "L+ ${d}/bin/geoip.dat - - - - ${vpx}/libexec/vpx/geoip.dat"
        "L+ ${d}/bin/geosite.dat - - - - ${vpx}/libexec/vpx/geosite.dat"
      ];
  };
}
