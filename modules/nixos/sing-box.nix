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
      ExecStart = [
        ""
        "${pkgs.sing-box}/bin/sing-box -C \"${conf-dir}\" run"
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
