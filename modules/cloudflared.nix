{
  config,
  username,
  ...
}:let
  jellyfin.uuid = "6bfd6ddf-582f-4fcf-854e-773635173768";
  cloudflared-service = {
    serviceConfig = {
      Environment = [
        "TUNNEL_TRANSPORT_PROTOCOL=http2"
      ];        
    };
  };
in  {
  sops.secrets = {
    "cloudflared/jellyfin" = {
      sopsFile = ../secrets/cloudflared-jellyfin.json;
      format = "json";
      key = "";
    };
  };
  systemd = {
    services = {
      "cloudflared-tunnel-${jellyfin.uuid}" = cloudflared-service;
    };
  };
  services.cloudflared = {
    enable = true;
    tunnels = {
      "${jellyfin.uuid}" = {
        credentialsFile = config.sops.secrets."cloudflared/jellyfin".path;
        default = "http_status:404";
        ingress = {
          "jellyfin.kkky.eu.org" = "http://127.0.0.1:8096";
        };
      };
    };
  };
}
