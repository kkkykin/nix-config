{
  lib,
  pkgs,
  ...
}: let
  pypi-mirror = "https://pypi.mirrors.ustc.edu.cn/simple";
in {
  home.packages = with pkgs; [
    _7zz-rar
    python3Full
    rclone
  ];
  programs = {
    uv = {
      enable = true;
    };
  };
}
