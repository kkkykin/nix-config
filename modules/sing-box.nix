{
  username,
  pkgs,
  lib,
  config,
  ...
}: {
  sops = {
    secrets.sing-box = {
      owner = username;
      sopsFile = ../secrets/sing-box.json;
      format = "json";
      key = "";
    };
  };
  systemd.services.sing-box = {
    serviceConfig = {
      User = username;
      AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
      ExecStart = [
        ""
        "${pkgs.unstable.sing-box}/bin/sing-box -c ${config.sops.secrets.sing-box.path} run"
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
