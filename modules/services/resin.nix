{
  config,
  secrets,
  ...
}: {
  services.resin = {
    enable = true;
    authVersion = "V1";
    listenAddress = "127.0.0.1";
    proxyBypass = "localhost;127.*;10.*;192.168.*";
    settings = {
      RESIN_PROBE_CONCURRENCY = "30";
    };
    environmentFile = config.sops.secrets.resin.path;
  };
}
