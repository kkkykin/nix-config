{
  config,
  secrets,
  username,
  pkgs,
  ...
}: let
  port = 18080;
in {

  services.romm = {
    enable = true;

    backend = "podman";
    image = "rommapp/romm:5.1.0";

    user = "romm";
    group = "romm";

    listenPort = port;

    environmentFile = config.sops.secrets.romm.path;
    # extraEnvironment = {
    #   LOGLEVEL = "DEBUG";
    # };

    hostName = "romm.${secrets.domain}";
    
    database = {
      driver = "postgresql";
      host = "host.containers.internal";
      port = 5432;
      user = "romm";
    };
  };

  services.cloudflared.tunnels."${secrets.cloudflared.uuid}" = {
    ingress = {
      "romm.${secrets.cloudflared.domain}" = "http://127.0.0.1:${toString port}";
    };
  };
}
