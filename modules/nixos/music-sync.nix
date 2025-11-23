{ config, pkgs, lib, ... }:

let
  syncScript = pkgs.writeShellScript "music-sync.sh" ''
    set -euo pipefail  # 任何错误立即退出
    
    MOUNT_POINT="/mnt/x7music/"
    SOURCE_DIR="/mnt/mediadata/jellyfin/music/"
    MOUNTED=false
    
    # 清理函数：确保卸载
    cleanup() {
      if [ "$MOUNTED" = true ]; then
        # 先尝试正常卸载，失败则使用 lazy umount
        umount "$MOUNT_POINT" 2>/dev/null || umount -l "$MOUNT_POINT"
      fi
    }
    trap cleanup EXIT INT TERM
    
    # 1. 检查挂载点
    [ -d "$MOUNT_POINT" ] || exit 1
    
    # 2. 挂载
    if ! mountpoint -q "$MOUNT_POINT"; then
      mount "$MOUNT_POINT"
      MOUNTED=true
    fi
    
    # 3. 检查源目录
    [ -d "$SOURCE_DIR" ] || exit 1
    [ -w "$MOUNT_POINT" ] || exit 1
    
    # 4. 同步
    rclone sync "$SOURCE_DIR" "$MOUNT_POINT"
    
    # 5. cleanup 会自动卸载
  '';
in
{
  # 定义定时服务
  systemd.services.music-sync = {
    description = "Sync music to x7music";
    
    startAt = "04:00";
    
    # 添加必要的命令到 PATH
    path = with pkgs; [ util-linux rclone ];
    
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${syncScript}";
      TimeoutStartSec = "1h";
    };
    
    after = [ "network-online.target" "local-fs.target" ];
    wants = [ "network-online.target" ];
  };
}
