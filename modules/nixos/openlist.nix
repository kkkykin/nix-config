{
  config,
  secrets,
  ...
}: {
  services.openlist = {
    enable = true;
    envFile = config.sops.secrets.openlist.path;
  };
  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "openlist.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "openlist.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts = {
    "http://openlist.asus.local" = {
      extraConfig = ''
reverse_proxy http://127.0.0.1:5244
'';
    };
  };
}
