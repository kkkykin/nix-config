{
  config,
  ...
}: {
  sops = {
    gnupg.home = "/root/.gnupg";
    defaultSopsFile = ../../secrets/users.yaml;
    secrets.kkky_pass.neededForUsers = true;
  }; 
  users = {
    mutableUsers = false;
    users.kkky = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGW5JyRHHcu6jcmH2tSQHGnWZJspvIZRkrB6XjFBFhQj openpgp:0x50A1F794"
      ];
      hashedPasswordFile = config.sops.secrets.kkky_pass.path;
    };
  };
}
