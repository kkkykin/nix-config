{
  config,
  secrets,
  ...
}:let
  cloudflared-service = {
    environment = {
      "TUNNEL_TRANSPORT_PROTOCOL" = "http2";
    };
  };
in  {
  systemd = {
    services = {
      "cloudflared-tunnel-${secrets.cloudflared.uuid}" = cloudflared-service;
    };
  };
  services.cloudflared = {
    enable = true;
    tunnels = {
      "${secrets.cloudflared.uuid}" = {
        edgeIPVersion = "auto";
        credentialsFile = config.sops.secrets."cloudflared".path;
        default = "http_status:404";
      };
    };
  };
}
