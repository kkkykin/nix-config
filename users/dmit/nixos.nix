{
  config,
  username,
  lib,
  secrets,
  ...
}: {
  users = {
    users."${username}" = {
      openssh.authorizedKeys.keys = [
        secrets.openssh.defaultKey
      ];
      hashedPasswordFile = config.sops.secrets.user_pass.path;
    };
  };
}
