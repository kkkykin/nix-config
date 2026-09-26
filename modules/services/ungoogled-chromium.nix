{
  config,
  pkgs,
  lib,
  ...
}:

let
  ungoogledChromiumUser = "ungoogled-chromium";
  stateDir = "/var/lib/ungoogled-chromium";
in
{
  users.groups.${ungoogledChromiumUser} = {};

  users.users.${ungoogledChromiumUser} = {
    isSystemUser = true;
    group = ungoogledChromiumUser;
    home = stateDir;
    createHome = true;
  };

  environment.systemPackages = with pkgs; [
    xpra
    ungoogled-chromium
  ];

  systemd.services.ungoogled-chromium = {
    description = "Ungoogled Chromium inside Xpra";

    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
    ];

    serviceConfig = {
      Type = "simple";

      User = ungoogledChromiumUser;
      Group = ungoogledChromiumUser;

      EnvironmentFile =
        config.sops.secrets."ungoogled-chromium".path;

      WorkingDirectory = stateDir;

      Restart = "always";
      RestartSec = 5;

      StateDirectory = "ungoogled-chromium";

      ExecStart = ''
        ${pkgs.xpra}/bin/xpra start :100 \
          --daemon=no \
          --html=on \
          --bind-tcp=127.0.0.1:14500 \
          --mdns=no \
          --pulseaudio=no \
          --notifications=no \
          --exit-with-children=yes \
          --start-child="${pkgs.ungoogled-chromium}/bin/chromium \
            --user-data-dir=${stateDir}/profile-0 \
            --no-first-run \
            --remote-debugging-port=9222 \
            --no-default-browser-check"
      '';

      NoNewPrivileges = true;

      ProtectSystem = "strict";

      ReadWritePaths = [
        stateDir
      ];

      PrivateTmp = true;
    };
  };
}
