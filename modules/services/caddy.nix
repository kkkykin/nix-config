{
  config,
  username,
  pkgs,
  ...
}: {
  systemd.services.caddy = {
    serviceConfig =
      pkgs.kkkykin.lib.serviceHardening
      // {
        # 1. 缩短停止超时时间
        # 当 l4remoteiplist 卡死时，最多等 10 秒就会强制杀掉进程
        TimeoutStopSec = "10s";

        # 2. 缩短启动/重载超时时间
        # 防止 reload 命令本身卡住太久
        TimeoutStartSec = "10s";

        # 3. 确保停止信号正确发送
        KillSignal = "SIGINT";
        KillMode = "mixed";

        CapabilityBoundingSet = [
          "CAP_NET_BIND_SERVICE"
        ];
        AmbientCapabilities = [
          "CAP_NET_BIND_SERVICE"
        ];
        ReadWritePaths = [config.services.caddy.logDir];
      };
  };

  services.caddy = {
    enable = true;
    package = pkgs.kkkykin.caddy-custom;
    globalConfig = ''
      ${builtins.readFile ./caddy/global/servers.Caddyfile}
      ${builtins.readFile ./caddy/global/misc.Caddyfile}
    '';
    extraConfig = ''
      ${builtins.readFile ./caddy/snippets/cors.Caddyfile}
      ${builtins.readFile ./caddy/snippets/lb.Caddyfile}
      ${builtins.readFile ./caddy/snippets/remove-forward-headers.Caddyfile}
      ${builtins.readFile ./caddy/snippets/trans-forward.Caddyfile}
    '';
  };
}
