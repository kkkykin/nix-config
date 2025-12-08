{
  pkgs,
  secrets,
  username,
  ...
}: {
  users.users.${username} = {
    extraGroups = ["jellyfin"];
  };
  services.jellyfin.enable = true;
  # https://github.com/jellyfin/jellyfin/issues/15667
  services.jellyfin.package = pkgs.pkg25-05.jellyfin;
  environment.systemPackages = with pkgs.pkg25-05; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  
  services.caddy.virtualHosts.":80".extraConfig = ''
reverse_proxy /opds/* http://127.0.0.1:8096
'';

  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "jellyfin.${secrets.cloudflared.asus.domain}" = "http://127.0.0.1:8096";
    };
  };

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      intel-ocl
      intel-media-driver
    ];
  };
}
