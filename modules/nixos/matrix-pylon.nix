{
  config,
  secrets,
  username,
  pkgs,
  ...
}: let
  network = "pylon-net";
in {

  systemd.services.podman-network-pylon-net = {
    serviceConfig.Type = "oneshot";

    before = [
      "podman-matrix-pylon.service"
      "podman-napcat.service"
    ];

    wantedBy = [
      "podman-matrix-pylon.service"
      "podman-napcat.service"
    ];

    script = ''
    ${pkgs.podman}/bin/podman network exists "${network}" ||
      ${pkgs.podman}/bin/podman network create "--subnet=10.89.1.0/24" "${network}"
    '';
  };

  systemd.services.podman-matrix-pylon.after = [
    "network-online.target"
    "sing-box.service"
  ];
  systemd.services.podman-napcat.after = ["podman-matrix-pylon.service"];

  virtualisation.oci-containers.containers.matrix-pylon.networks = [ network ];
  virtualisation.oci-containers.containers.napcat.networks = [ network ];

  services.matrix-pylon = {
    enable = true;
    backend = "podman";
    image = "lxduo/matrix-pylon:v0.0.3";
    listenPort = 23456;
    publishPort = true;
    environmentFile = config.sops.secrets.matrix-pylon.path;
    openFirewall = true;
    extraOptions = [ "--ip=10.89.1.128" ];
  };

  services.napcat = {
    enable = true;
    backend = "podman";
    image = "mlikiowa/napcat-docker:v4.18.13";
    environmentFile = config.sops.secrets.napcat.path;
    extraOptions = [ "--ip=10.89.1.129" ];
  };
}
