{
  pkgs,
  config,
  ...
}: let
  baseDir = "/mnt/mediadata/calibre";
  pkg = pkgs.kkkykin.calibre-no-speech;
  user = config.services.calibre-server.user;
in {
  environment.systemPackages = [pkg];
  systemd.tmpfiles.rules = [
    "A+ ${baseDir} - - - - u:${user}:rwX,d:u:${user}:rwx"
  ];
  services.calibre-server = {
    enable = true;
    package = pkg;
    host = "127.0.0.1";
    openFirewall = false;
    auth = {
      enable = true;
      mode = "basic";
      userDb = "${baseDir}/users.sqlite";
    };
    libraries = [
      "${baseDir}/books"
      "${baseDir}/comic"
    ];
  };

  systemd.services.calibre-server.serviceConfig =
    pkgs.kkkykin.lib.serviceHardening
    // {
      ReadWritePaths = [baseDir config.users.users.${user}.home];
    };

  my.webApps.calibre = {
    tunnel = false;
    caddyConfig = "reverse_proxy http://127.0.0.1:${toString config.services.calibre-server.port}";
  };
}
