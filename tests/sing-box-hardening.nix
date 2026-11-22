# nix-instantiate --eval --strict --json tests/sing-box-hardening.nix --arg nixpkgs /path/to/nixpkgs
{
  nixpkgs,
  nurPackages ? ../../nur-packages,
  system ? "x86_64-linux",
}: let
  lib = import (nixpkgs + "/lib");
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      (final: prev: {
        unstable = prev;
        kkkykin.lib.serviceHardening = import (nurPackages + "/lib/service-hardening.nix") {inherit lib;};
      })
    ];
  };
  evaluate = extra:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit system pkgs;
      specialArgs.username = "deployer";
      modules = [
        ../modules/services/sing-box.nix
        {system.stateVersion = "26.05";}
        extra
      ];
    }).config;
  config = evaluate {};
  client = evaluate {my.sing-box.configFiles = ["/etc/sing-box/client/500-tun.json"];};
  server = evaluate {
    my.sing-box.configFiles = [
      "/etc/sing-box/server/500-main.json"
      "/etc/sing-box/server/500-dns.json"
      "/etc/sing-box/server/500-s0.json"
    ];
  };
  service = config.systemd.services.sing-box.serviceConfig;
  unit = config.systemd.units."sing-box.service".text;
  networkCapabilities = ["" "CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE"];
  checks = {
    dedicatedServiceUser = service.User == "sing-box" && service.Group == "sing-box";
    readOnlyConfig = service.ConfigurationDirectory == "" && builtins.elem "/etc/sing-box/" service.ReadOnlyPaths;
    privateWritableState = service.StateDirectory == "sing-box" && service.StateDirectoryMode == "0700";
    stateWorkingDirectory = service.WorkingDirectory == "/var/lib/sing-box" && lib.hasInfix "-D \${STATE_DIRECTORY}" unit;
    directTunConfig = lib.hasInfix ''"-c" "/etc/sing-box/client/500-tun.json"'' client.systemd.units."sing-box.service".text;
    separateServerFragments = lib.hasInfix ''"-c" "/etc/sing-box/server/500-main.json" "-c" "/etc/sing-box/server/500-dns.json" "-c" "/etc/sing-box/server/500-s0.json"'' server.systemd.units."sing-box.service".text;
    deploymentGroupInheritance = builtins.elem "d /etc/sing-box/ 2750 deployer sing-box -" config.systemd.tmpfiles.rules;
    noDacOrPtraceBypass = service.CapabilityBoundingSet == networkCapabilities && service.AmbientCapabilities == networkCapabilities;
    tunStillAvailable = !service.PrivateDevices && builtins.elem "/dev/net/tun rw" service.DeviceAllow && !service.ProtectKernelTunables;
    sandboxRetained = service.ProtectSystem == "strict" && service.ProtectHome && service.NoNewPrivileges;
  };
in
  assert lib.assertMsg (lib.all (result: result) (builtins.attrValues checks))
  "sing-box hardening regressions failed: ${lib.concatStringsSep ", " (builtins.attrNames (lib.filterAttrs (_: result: !result) checks))}"; checks
