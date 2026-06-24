{
  config,
  pkgs,
  lib,
  ...
}:

let
  fingerprint-chromiumUser = "fingerprint-chromium";
in
{
  users.groups.${fingerprint-chromiumUser} = {};

  users.users.${fingerprint-chromiumUser} = {
    isSystemUser = true;
    group = fingerprint-chromiumUser;
    home = "/var/lib/fingerprint-chromium";
    createHome = true;
  };

  environment.systemPackages = with pkgs; [
    xpra
    kkkykin.fingerprint-chromium
  ];

  systemd.services.fingerprint-chromium = {
    description = "Fingerprint-Chromium inside Xpra";

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";

      User = fingerprint-chromiumUser;
      Group = fingerprint-chromiumUser;

      EnvironmentFile = config.sops.secrets."fingerprint-chromium".path;

      WorkingDirectory = "/var/lib/fingerprint-chromium";

      Restart = "always";
      RestartSec = 5;

      StateDirectory = "fingerprint-chromium";

      ExecStart = ''
        ${pkgs.xpra}/bin/xpra start :100 \
          --daemon=no \
          --html=on \
          --bind-tcp=127.0.0.1:14500 \
          --mdns=no \
          --pulseaudio=no \
          --notifications=no \
          --exit-with-children=yes \
          --start-child="${pkgs.kkkykin.fingerprint-chromium}/bin/fingerprint-chromium \
            --user-data-dir=/var/lib/fingerprint-chromium/profile-0 \
            --no-first-run \
            --remote-debugging-port=9222 \
            --timezone=America/Los_Angeles \
            --no-default-browser-check \
            --disable-features=Translate"
      '';

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/fingerprint-chromium" ];
      PrivateTmp = true;
    };
  };
}
