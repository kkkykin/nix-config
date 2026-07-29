{
  config,
  secrets,
  ...
}: {
  services.proxy-checker = {
    enable = true;
    port = 8888;
    environmentFile = config.sops.secrets.proxy-checker.path;
  };
}
