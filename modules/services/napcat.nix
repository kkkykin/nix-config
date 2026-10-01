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
    image = "mlikiowa/napcat-docker:v4.18.28";
    publishPorts = true;
    environmentFile = config.sops.secrets.napcat.path;
  };
}
