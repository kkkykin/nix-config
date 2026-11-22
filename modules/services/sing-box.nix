{
  username,
  pkgs,
  lib,
  config,
  ...
}: let
  conf-dir = "/etc/sing-box/";
  singbox = pkgs.unstable.sing-box;
in {
  environment.systemPackages = [singbox];
  systemd.tmpfiles.rules = [
    "d ${conf-dir} 0770 ${username} sing-box -"
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
          "${singbox}/bin/sing-box -C \"${conf-dir}\" run"
        ];

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
}
