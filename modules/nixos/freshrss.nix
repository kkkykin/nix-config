{
  pkgs,
  secrets,
  config,
  username,
  ...
}: let
  host = "freshrss.asus.local";
in {

  services.freshrss = {
    enable = true;
    package = pkgs.unstable.freshrss;
    webserver = "caddy";
    defaultUser = username;
    passwordFile = config.sops.secrets."freshrss_user_pass".path;
    baseUrl = "http://${host}";
    virtualHost = "http://${host}";
    language = "en";
    database = {
      type = "pgsql";
      name = "freshrss";
      user = "freshrss";
      host = "127.0.0.1";
      port = 5432;
      passFile = config.sops.secrets."freshrss_db_pass".path;
    };
  };

  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "freshrss.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = host;
        };
      };
    };
  };
}
