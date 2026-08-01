{
  pkgs,
  secrets,
  config,
  ...
}: let
  backend = "http://127.0.0.1:25600";
in {
  services.cloudflared.tunnels."${secrets.cloudflared.uuid}" = {
    ingress = {
      "komga.${secrets.cloudflared.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "komga.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts = {
    ":80" = {
      extraConfig = ''
reverse_proxy /opds/v2/* ${backend}
'';
    };
    "http://komga.asus.local" = {
      extraConfig = ''
reverse_proxy ${backend}
'';
    };
  };
  services.komga = {
    enable = true;
    settings = {
      server = {
        port = 25600;
      };
    };
  };
}
