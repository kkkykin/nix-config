# VPS 上的普通用户（cone-vps / dmit-vps）
{
  config,
  username,
  secrets,
  ...
}: {
  users.users.${username} = {
    openssh.authorizedKeys.keys = [
      secrets.openssh.defaultKey
    ];
    hashedPasswordFile = config.sops.secrets.user_pass.path;
  };
}
