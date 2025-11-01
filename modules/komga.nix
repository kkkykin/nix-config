{
  pkgs,
  secrets,
  config,
  ...
}: let
  backend = "http://127.0.0.1:25600";
  kosync-fix = ''
@koreaderSync {
  method GET
  header Accept "application/vnd.koreader.v1+json"
  path /koreader/syncs/progress/*
}

reverse_proxy @koreaderSync ${backend} {
  header_down Content-Type application/json
}
'';
in {
  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "komga.${secrets.cloudflared.asus.domain}" = {
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
reverse_proxy /opds/v1.2/* ${backend}
'';
    };
    "http://komga.asus.local" = {
      extraConfig = ''
${kosync-fix}
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
