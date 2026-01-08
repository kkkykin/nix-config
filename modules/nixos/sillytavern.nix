{
  config,
  secrets,
  pkgs,
  ...
}: let
  port = 8045;
  url = "http://127.0.0.1:${toString config.services.sillytavern.port}";
in {
  services = {
    sillytavern = {
      enable = true;
      whitelist = true;
      package = pkgs.sillytavern;
      port = port;
      configFile = config.sops.secrets.sillytavern.path;
    };
  };
  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "sillytavern.${secrets.cloudflared.asus.domain}" = url;
    };
  };
  services.caddy.virtualHosts = {
    "http://sillytavern.asus.local" = {
      extraConfig = ''
reverse_proxy ${url} {
  flush_interval -1
}
'';
    };
  };
}
