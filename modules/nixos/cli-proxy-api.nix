{
  config,
  secrets,
  username,
  pkgs,
  ...
}: {
  users.users.${username} = {
    extraGroups = ["cli-proxy-api"];
  };

  environment.systemPackages = with pkgs; [
    cli-proxy-api
  ];

  services = {
    cli-proxy-api = {
      enable = true;
      configFile = "${config.services.cli-proxy-api.homeDir}/config.yaml";
      # environmentFile = config.sops.secrets.cli-proxy-api.path;
    };
    cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
      ingress = {
        "cpa.${secrets.cloudflared.asus.domain}" = {
          service = "http://127.0.0.1";
          originRequest = {
            httpHostHeader = "cpa.asus.local";
          };
        };
      };
    };
    caddy.virtualHosts = {
      "http://cpa.asus.local" = {
        extraConfig = ''
reverse_proxy http://127.0.0.1:8317
        '';
      };
    };
    postgresql = {
      ensureDatabases = [
        "cli-proxy-api"
      ];
      ensureUsers = [
        {
          name = "cli-proxy-api";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
