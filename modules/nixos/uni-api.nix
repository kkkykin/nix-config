{
  config,
  secrets,
  pkgs,
  ...
}:
let
  configHost = "http://${secrets.private-www.host}:${toString secrets.private-www.port}";
  configPath = "/api.yaml";
in
{
  services = {
    uni-api = {
      enable = true;
      package = pkgs.kkkykin.uni-api;
      envFile = config.sops.secrets.uni-api.path;
      extraEnvVars = {
        CONFIG_URL = "${configHost}${configPath}";
      };
    };
  };

  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "uni-api.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "uni-api.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts = {
    "http://uni-api.asus.local" = {
      extraConfig = ''
reverse_proxy http://127.0.0.1:${toString config.services.uni-api.port}
'';
    };
  };
}
