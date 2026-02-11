{
  secrets,
  ...
}: {
  networking.nftables.enable = true;

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      openFirewall = true;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    secrets.openssh.defaultKey
  ];

}
