{
  pkgs,
  secrets,
  ...
}: {
  environment.systemPackages = with pkgs; [
    fdroidserver
    sdkmanager
    jdk
  ];

  my.webApps.fdroid.caddyConfig = ''
root ${secrets.fdroid.dir}
@blocked {
  path /repo/status/*
}
respond @blocked 404
@allowd {
  path /repo/*
}
file_server @allowd
'';
}
