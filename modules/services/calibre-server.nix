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
    openFirewall = true;
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
}
