{
  config,
  lib,
  ...
}: {
  users = {
    users.kkky = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGW5JyRHHcu6jcmH2tSQHGnWZJspvIZRkrB6XjFBFhQj openpgp:0x50A1F794"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPL37w2FQh7/LPCL32EISGASLgYale9S3r2JOgyOt5GE wireshark"
      ];
      hashedPasswordFile = config.sops.secrets.kkky_pass.path;
    };
  };
}
