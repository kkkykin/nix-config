# nix-instantiate --eval --strict --json tests/sing-box-hardening.nix --arg nixpkgs /path/to/nixpkgs
{
  nixpkgs,
  system ? "x86_64-linux",
}: let
  lib = import (nixpkgs + "/lib");
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      (final: prev: {
        unstable = prev;
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
  checks = {
    dedicatedServiceUser = service.User == "sing-box" && service.Group == "sing-box";
    readOnlyConfig = service.ConfigurationDirectory == "" && builtins.elem "/etc/sing-box/" service.ReadOnlyPaths;
    privateWritableState = service.StateDirectory == "sing-box" && service.StateDirectoryMode == "0700";
    stateWorkingDirectory = service.WorkingDirectory == "/var/lib/sing-box" && lib.hasInfix "-D \${STATE_DIRECTORY}" unit;
    directTunConfig = lib.hasInfix ''"-c" "/etc/sing-box/client/500-tun.json"'' client.systemd.units."sing-box.service".text;
    separateServerFragments = lib.hasInfix ''"-c" "/etc/sing-box/server/500-main.json" "-c" "/etc/sing-box/server/500-dns.json" "-c" "/etc/sing-box/server/500-s0.json"'' server.systemd.units."sing-box.service".text;
    deploymentGroupInheritance = builtins.elem "d /etc/sing-box/ 2750 deployer sing-box -" config.systemd.tmpfiles.rules;
    upstreamUnitIsExtended =
      builtins.elem config.systemd.units."sing-box.service".overrideStrategy ["asDropin" "asDropinIfExists"]
      && lib.any (package: package.outPath == config.services.sing-box.package.outPath) config.systemd.packages;
    upstreamCapabilitiesInherited = !(service ? CapabilityBoundingSet) && !(service ? AmbientCapabilities);
    crossUserProcessesVisible = (service.ProtectProc or "default") == "default" && (service.ProcSubset or "all") == "all";
    hostUsersAndInterfacesVisible = !(service.PrivateUsers or false) && !(service.PrivateNetwork or false);
    upstreamDeviceAndKernelAccess = !(service.PrivateDevices or false) && !(service.ProtectKernelTunables or false) && !(service ? DevicePolicy) && !(service ? DeviceAllow);
    upstreamNamespacesRetained = !(service.RestrictNamespaces or false);
    sandboxRetained = service.ProtectSystem == "strict" && service.ProtectHome && service.NoNewPrivileges && service.PrivateTmp && service.UMask == "0077";
  };
in
  assert lib.assertMsg (lib.all (result: result) (builtins.attrValues checks))
  "sing-box hardening regressions failed: ${lib.concatStringsSep ", " (builtins.attrNames (lib.filterAttrs (_: result: !result) checks))}"; checks
