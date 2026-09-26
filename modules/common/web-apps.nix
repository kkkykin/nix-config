# 局域网 Web 服务的统一入口：
#   my.webApps.<name> 会���成 caddy 虚拟主机 http://<name>.<lanDomain>，
#   并（默认）通过 cloudflared 隧道暴露为 <name>.<secrets.cloudflared.domain>
{
  config,
  lib,
  secrets,
  ...
}: let
  inherit (lib) mkOption types mapAttrs' nameValuePair filterAttrs;
  cfg = config.my;
  lanHost = name: "${name}.${cfg.lanDomain}";
in {
  options.my = {
    lanDomain = mkOption {
      type = types.str;
      example = "asus.local";
      description = "局域网内虚拟主机使用的域名后缀";
    };

    webApps = mkOption {
      default = {};
      type = types.attrsOf (types.submodule {
        options = {
          caddyConfig = mkOption {
            type = types.nullOr types.lines;
            default = null;
            description = "caddy 站点配置；为 null 时不生成虚拟主机（由服务模块自行生成）";
          };
          serverAliases = mkOption {
            type = types.listOf types.str;
            default = [];
          };
          tunnel = mkOption {
            type = types.bool;
            default = true;
            description = "是否通过 cloudflared 隧道暴露";
          };
        };
      });
    };
  };

  config = {
    services.caddy.virtualHosts =
      mapAttrs' (name: app:
        nameValuePair "http://${lanHost name}" {
          inherit (app) serverAliases;
          extraConfig = app.caddyConfig;
        })
      (filterAttrs (_: app: app.caddyConfig != null) cfg.webApps);

    services.cloudflared.tunnels.${secrets.cloudflared.uuid}.ingress =
      mapAttrs' (name: _:
        nameValuePair "${name}.${secrets.cloudflared.domain}" {
          service = "http://127.0.0.1";
          originRequest.httpHostHeader = lanHost name;
        })
      (filterAttrs (_: app: app.tunnel) cfg.webApps);
  };
}
