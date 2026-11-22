{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  mountPoint = "/mnt/x7music";
  sourceDir = "/mnt/mediadata/jellyfin/music";
  destination = config.fileSystems.${mountPoint};
  syncScript = pkgs.writeShellScript "music-sync.sh" ''
    set -euo pipefail
    mountpoint -q ${lib.escapeShellArg mountPoint}
    test -d ${lib.escapeShellArg sourceDir}
    test -w ${lib.escapeShellArg mountPoint}
    exec rclone sync ${lib.escapeShellArg sourceDir} ${lib.escapeShellArg mountPoint}
  '';
in {
  users.groups.music-sync = {};
  users.users.music-sync = {
    isSystemUser = true;
    group = "music-sync";
  };
  users.users.${username}.extraGroups = ["music-sync"];

  # libmount resolves the group name at mount time; no fixed GID is needed.
  fileSystems.${mountPoint}.options = ["gid=music-sync" "fmask=0117" "dmask=0007"];
  systemd.mounts = [
    {
      what = destination.device;
      where = mountPoint;
      type = destination.fsType;
      options = lib.concatStringsSep "," destination.options;
      unitConfig.StopWhenUnneeded = true;
    }
  ];

  # 定义定时服务
  systemd.services.music-sync = {
    description = "Sync music to x7music";

    startAt = "04:00";

    # 添加必要的命令到 PATH
    path = with pkgs; [util-linux rclone];

    unitConfig.RequiresMountsFor = [mountPoint sourceDir];

    serviceConfig =
      pkgs.kkkykin.lib.serviceHardening
      // {
        Type = "oneshot";
        User = "music-sync";
        Group = "music-sync";
        # Apply read access after the source disk is mounted, including new files.
        # Only this fixed setup command runs privileged; rclone has no capabilities.
        ExecStartPre = "+${pkgs.acl}/bin/setfacl -R -m u:music-sync:rX ${sourceDir}";
        ExecStart = "${syncScript}";
        ReadOnlyPaths = [sourceDir];
        ReadWritePaths = [mountPoint];
        PrivateNetwork = true;
        TimeoutStartSec = "1h";
      };

    after = ["local-fs.target"];
  };
}
