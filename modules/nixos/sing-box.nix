{
  username,
  pkgs,
  lib,
  config,
  ...
}: let
  conf-dir = "/etc/sing-box/";
in{

  systemd.tmpfiles.rules = [
    "d ${conf-dir} 0770 ${username} sing-box -"
  ];

  users.users.${username} = {
    extraGroups = ["sing-box"];
  };

  systemd.services.sing-box = {
    serviceConfig = {
      AmbientCapabilities = [
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_ADMIN"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
      ];
      ExecStart = [
        ""
        "${pkgs.sing-box}/bin/sing-box -c \"${conf-dir}/client/500-tun.json\" run"
      ];
    };
  };
  services = {
    sing-box = {
      enable = true;
      package = pkgs.sing-box;
    };
  };
}
