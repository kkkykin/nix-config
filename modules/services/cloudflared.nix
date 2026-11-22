{
  config,
  secrets,
  pkgs,
  lib,
  ...
}: let
  cloudflared-service = {
    serviceConfig = pkgs.kkkykin.lib.serviceHardening;
    environment = {
      "TUNNEL_TRANSPORT_PROTOCOL" = "http2";
    };
  };
in {
  systemd = {
    services = lib.mkIf config.services.cloudflared.enable {
      "cloudflared-tunnel-${secrets.cloudflared.uuid}" = cloudflared-service;
    };
  };
  services.cloudflared = {
    enable = false;
    tunnels = {
      "${secrets.cloudflared.uuid}" = {
        edgeIPVersion = "auto";
        credentialsFile = config.sops.secrets."cloudflared".path;
        default = "http_status:404";
      };
    };
  };
}
