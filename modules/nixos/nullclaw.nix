{
  config,
  secrets,
  pkgs,
  ...
}: {
  services = {
    nullclaw = {
      enable = true;
      configFile = config.sops.secrets.nullclaw.path;
    };
  };
}
