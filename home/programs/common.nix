{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    _7zz-rar
  ];
}
