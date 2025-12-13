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
