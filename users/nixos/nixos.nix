{
  config,
  ...
}: {
  sops = {
    gnupg.home = "/root/.gnupg";
    defaultSopsFile = ../../secrets/users.yaml;
    secrets.nixos_pass.neededForUsers = true;
  };
  users = {
    users.nixos = {
      hashedPasswordFile = config.sops.secrets.nixos_pass.path;
    };
  };
}
