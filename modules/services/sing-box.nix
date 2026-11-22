{
  username,
  pkgs,
  lib,
  config,
  utils,
  ...
}: let
  conf-dir = "/etc/sing-box/";
  singbox = pkgs.unstable.sing-box;
  configArgs =
    if config.my.sing-box.configFiles == []
    then ["-C" conf-dir]
    else lib.concatMap (file: ["-c" file]) config.my.sing-box.configFiles;
in {
  options.my.sing-box.configFiles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = ''
      Runtime configuration files to load directly, without top-level symlinks.
      An empty list keeps loading /etc/sing-box for existing server deployments.
    '';
  };

  config = {
    environment.systemPackages = [singbox];
    systemd.tmpfiles.rules = [
      # The deployer writes configs; the service only reads them. New directories
      # and staged replacements inherit the sing-box group through setgid.
      "d ${conf-dir} 2750 ${username} sing-box -"
    ];

    users.users.${username} = {
      extraGroups = ["sing-box"];
    };

    systemd.services.sing-box = {
      # Inherit capabilities, process/network/device access from the packaged
      # upstream unit, and the service user/state directories from NixOS.
      # Generic application sandbox defaults conflict with TUN/process routing.
      serviceConfig = {
        ExecStart = [
          ""
          "${singbox}/bin/sing-box -D \${STATE_DIRECTORY} ${utils.escapeSystemdExecArgs configArgs} run"
        ];
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        UMask = "0077";

        # tmpfiles owns the deployed configs; StateDirectory remains writable.
        # Avoid ConfigurationDirectory making /etc/sing-box a writable exception.
        ConfigurationDirectory = lib.mkForce "";
        ReadOnlyPaths = [conf-dir];
      };
    };
    services = {
      sing-box = {
        enable = true;
        package = singbox;
      };
    };
  };
}
