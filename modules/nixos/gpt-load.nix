{
  config,
  secrets,
  ...
}: {
  services = {
    gpt-load = {
      enable = true;
      environmentFile = config.sops.secrets.gpt-load.path;
    };
  };

  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "gpt-load.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "gpt-load.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts = {
    "http://gpt-load.asus.local" = {
      extraConfig = ''
reverse_proxy http://127.0.0.1:${toString config.services.gpt-load.port}
'';
    };
  };
}
