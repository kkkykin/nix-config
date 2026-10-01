{
  pkgs,
  secrets,
  config,
  username,
  ...
}: let
  host = "freshrss.${config.my.lanDomain}";
in {
  imports = [./postgresql.nix];

  services.freshrss = {
    enable = true;
    package = pkgs.freshrss;
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

  # 虚拟主机由 services.freshrss 生成，这里只开隧道
  my.webApps.freshrss = {};

  services.postgresql = {
    ensureDatabases = ["freshrss"];
    ensureUsers = [
      {
        name = "freshrss";
        ensureDBOwnership = true;
      }
    ];
    authentication = "host freshrss freshrss 127.0.0.1/32 scram-sha-256";
  };
}
