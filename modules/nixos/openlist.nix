{
  config,
  ...
}: {
  services.openlist = {
    enable = true;
    envFile = config.sops.secrets.openlist.path;
  };
}
