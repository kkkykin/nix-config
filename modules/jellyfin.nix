{
  pkgs,
  secrets,
  ...
}: {
  services.jellyfin.enable = true;
  environment.systemPackages = with pkgs; [
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

  specialisation.gpu.configuration = {
    hardware.graphics = {
      enable = true;

      extraPackages = with pkgs; [
        intel-ocl
        intel-media-driver
      ];
    };
  };
}
