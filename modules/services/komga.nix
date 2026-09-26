{
  pkgs,
  config,
  ...
}: let
  backend = "http://127.0.0.1:25600";
in {
  my.webApps.komga.caddyConfig = "reverse_proxy ${backend}";

  services.caddy.virtualHosts = {
    ":80" = {
      extraConfig = ''
reverse_proxy /opds/v1.2/* ${backend}
reverse_proxy /opds/v2/* ${backend}
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
