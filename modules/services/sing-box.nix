{
  username,
  pkgs,
  lib,
  config,
  ...
}: let
  conf-dir = "/etc/sing-box/";
  singbox = pkgs.unstable.sing-box;
in {
  environment.systemPackages = [singbox];
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
        "${singbox}/bin/sing-box -C \"${conf-dir}\" run"
      ];
    };
  };
  services = {
    sing-box = {
      enable = true;
      package = singbox;
    };
  };
}
