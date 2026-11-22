{
  config,
  secrets,
  username,
  pkgs,
  ...
}: {
  services.napcat = {
    enable = true;
    backend = "podman";
    image = "mlikiowa/napcat-docker:v4.18.42";
    publishPorts = true;
    webuiListenAddress = "127.0.0.1";
    # Matterbridge on dmit-vps connects to OneBot across hosts.
    onebotListenAddress = "0.0.0.0";
    environmentFile = config.sops.secrets.napcat.path;
  };
}
