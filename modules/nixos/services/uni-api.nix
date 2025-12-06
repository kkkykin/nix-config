{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.uni-api;
  execFlags = (
    concatStringsSep " " (
      mapAttrsToList (k: v: "${k} ${toString v}") (
        filterAttrs (name: value: value != null) {
          "--host" = cfg.host;
          "--port" = cfg.port;
        }
      )
    )
  );
in {
  options.services.uni-api = {
    enable = mkEnableOption "uni-api daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.uni-api;
      description = "uni-api binary package";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "::1";
      description = ''
        The interface on which to listen for connections.
      '';
    };

    port = lib.mkOption {
      default = 3031;
      type = lib.types.port;
      description = ''
        The port on which to listen for connections.
      '';
    };

    extraEnvVars = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional environment variables";
    };

    envFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = literalExpression "./files/myenv";
      description = "Environment file (KEY=value) passed to systemd";
    };

    user  = mkOption {
      type = types.str;
      default = "uni-api";
      description = "User to run uni-api";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
    };
    users.groups.${cfg.user} = {};

    systemd.services.uni-api = {
      description = "Unified API gateway for multiple AI model providers";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network.target" ];

      environment = cfg.extraEnvVars;  

      serviceConfig = {
        User             = cfg.user;
        Group            = cfg.user;
        ExecStart        = "${cfg.package}/bin/uni-api ${execFlags}";
        Restart          = "on-failure";
        EnvironmentFile  = mkIf (cfg.envFile != null) cfg.envFile;
      };
    };
  };
}
