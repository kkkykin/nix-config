{
  pkgs,
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

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      intel-ocl
      intel-media-driver
    ];
  };
}
