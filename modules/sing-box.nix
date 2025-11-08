{
  username,
  dotfileDir,
  pkgs,
  lib,
  config,
  ...
}: {
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };
  systemd.services.sing-box = {
    serviceConfig = {
      User = username;
      AmbientCapabilities = [
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_ADMIN"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
      ];
      ExecStart = [
        ""
        "${pkgs.unstable.sing-box}/bin/sing-box -c \"${dotfileDir}/sing-box/_tangle/client/500-tun.json\" run"
      ];
    };
  };
  services = {
    sing-box = {
      enable = true;
      package = pkgs.unstable.sing-box;
    };
  };
  networking = {
    nftables = {
      enable = true;
    };
    firewall = {
      allowedTCPPorts = [
        10807
      ];
    };
  };
}
