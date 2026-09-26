{
  config,
  secrets,
  ...
}: {
  imports = [./postgresql.nix];

  users.users.${config.services.openlist.user} = {
    extraGroups = ["aria2"];
  };
  services.openlist = {
    enable = true;
    envFile = config.sops.secrets.openlist.path;
  };
  my.webApps.openlist.caddyConfig = "reverse_proxy http://127.0.0.1:5244";

  services.postgresql = {
    ensureDatabases = ["openlist"];
    ensureUsers = [
      {
        name = "openlist";
        ensureDBOwnership = true;
      }
    ];
    authentication = "host openlist openlist 127.0.0.1/32 scram-sha-256";
  };
}
