{
  lib,
  pkgs,
  ...
}: let
  pypi-mirror = "https://pypi.mirrors.ustc.edu.cn/simple";
in {
  home.packages = with pkgs; [
    _7zz-rar
    (libarchive.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ lz4 ];
    }))
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
