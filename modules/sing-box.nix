{
  username,
  dotfileDir,
  pkgs,
  lib,
  config,
  ...
}: {
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
}
