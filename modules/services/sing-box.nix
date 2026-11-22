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
      serviceConfig =
        pkgs.kkkykin.lib.serviceHardening
        // {
          ExecStart = [
            ""
            "${singbox}/bin/sing-box -D \${STATE_DIRECTORY} ${utils.escapeSystemdExecArgs configArgs} run"
          ];
          StateDirectory = "sing-box";
          StateDirectoryMode = "0700";
          WorkingDirectory = "/var/lib/sing-box";

          # Reset the capabilities inherited from the upstream unit. TUN and
          # transparent routing need network capabilities, not ptrace/DAC bypass.
          CapabilityBoundingSet = lib.mkForce [
            ""
            "CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE"
          ];
          AmbientCapabilities = lib.mkForce [
            ""
            "CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE"
          ];
          PrivateDevices = false;
          DevicePolicy = "closed";
          DeviceAllow = ["/dev/net/tun rw"];
          # auto_redirect may update network sysctls when configuring TUN routes.
          ProtectKernelTunables = false;
          # tmpfiles owns this external config directory. Do not let systemd's
          # ConfigurationDirectory make it a writable exception to ProtectSystem.
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
