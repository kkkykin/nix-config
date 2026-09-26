{
  username,
  pkgs,
  ...
}: {
  virtualisation = {
    containers.enable = true;
    containers.registries.search = [
      "docker.io"
      "ghcr.io"
    ];
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment = {
    shellAliases = {
      docker-compose = "podman-compose";
    };
    systemPackages = [
      pkgs.podman-compose
    ];
  };

  users.users."${username}" = {
    extraGroups = [
      "podman"
    ];
  };
}
