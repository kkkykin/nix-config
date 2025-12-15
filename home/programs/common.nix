{
  lib,
  pkgs,
  ...
}: let
  pypi-mirror = "https://pypi.mirrors.ustc.edu.cn/simple";
in {
  home.packages = with pkgs; [
    kkkykin.c7zip-unfree
    android-tools
    python3
    rclone
  ];
  programs = {
    uv = {
      enable = true;
    };
  };
}
