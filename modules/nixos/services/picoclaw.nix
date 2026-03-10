{ config, lib, pkgs, ... }:
 
let
  cfg = config.services.picoclaw;
  picoclawPackage = pkgs.picoclaw;
in {
  options.services.picoclaw = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable PicoClaw AI assistant service";
    };
 
    package = lib.mkOption {
      type = lib.types.package;
      default = picoclawPackage;
      description = "PicoClaw package to use";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = lib.literalExpression "[ pkgs.jq ]";
      description = "Extra packages to add to the nullclaw service environment PATH.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to an environment file.
      '';
    };
 
    user = lib.mkOption {
      type = lib.types.str;
      default = "picoclaw";
      description = "User account under which PicoClaw runs";
    };
 
    group = lib.mkOption {
      type = lib.types.str;
      default = "picoclaw";
      description = "Group account under which PicoClaw runs";
    };
 
    homeDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/picoclaw";
      description = "PicoClaw home directory (PICOCLAW_HOME)";
    };
 
    configFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/picoclaw/config.json";
      description = "Path to PicoClaw configuration file (PICOCLAW_CONFIG)";
    };
 
    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf (lib.types.nullOr lib.types.str);
      default = {};
      example = {
        OPENAI_API_KEY = "sk-xxxxx";
        LANG = "en_US.UTF-8";
      };
      description = "Additional environment variables for PicoClaw";
    };
 
    debug = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable debug mode";
    };
  };
 
  config = lib.mkIf cfg.enable {
    users.users.picoclaw = lib.mkIf (cfg.user == "picoclaw") {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.homeDir;
      createHome = true;
      description = "PicoClaw AI assistant service";
    };
 
    users.groups.picoclaw = lib.mkIf (cfg.group == "picoclaw") {};
 
    systemd.services.picoclaw = {
      description = "PicoClaw AI Assistant Gateway";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = with pkgs; [
        _7zz
        curl
        git
        python3
        uv
        nodejs
        jq
        bash
        file
      ] ++ cfg.extraPackages;
      
      environment = {
        PICOCLAW_HOME = cfg.homeDir;
        PICOCLAW_CONFIG = cfg.configFile;
      } // cfg.extraEnvironment;
      
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.homeDir;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        
        Restart = "on-failure";
        RestartSec = "5s";
        
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.homeDir ];
        
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "picoclaw";
      };
 
      script = ''
        ${lib.getExe cfg.package} gateway ${lib.optionalString cfg.debug "--debug"}
      '';
    };
  };
}
