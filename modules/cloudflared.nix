{
  config,
  secrets,
  ...
}:let
  cloudflared-service = {
    serviceConfig = {
      Environment = [
        "TUNNEL_TRANSPORT_PROTOCOL=http2"
      ];        
    };
  };
in  {
  systemd = {
    services = {
      "cloudflared-tunnel-${secrets.cloudflared.asus.uuid}" = cloudflared-service;
    };
  };
  services.cloudflared = {
    enable = true;
    tunnels = {
      "${secrets.cloudflared.asus.uuid}" = {
        credentialsFile = config.sops.secrets."cloudflared/asus".path;
        default = "http_status:404";
      };
    };
  };
}
