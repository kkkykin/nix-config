{
  config,
  secrets,
  username,
  pkgs,
  ...
}: let
  port = 18080;
in {
  imports = [./postgresql.nix];

  services.romm = {
    enable = true;

    backend = "podman";
    image = "rommapp/romm:5.2.0";

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

  services.postgresql = {
    ensureDatabases = ["romm"];
    ensureUsers = [
      {
        name = "romm";
        ensureDBOwnership = true;
      }
    ];
    # romm 跑在 podman 容器中
    authentication = "host romm romm 10.88.0.0/16 scram-sha-256";
  };

  services.cloudflared.tunnels."${secrets.cloudflared.uuid}" = {
    ingress = {
      "romm.${secrets.cloudflared.domain}" = "http://127.0.0.1:${toString port}";
    };
  };
}
