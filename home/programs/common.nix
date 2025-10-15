{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    p7zip-rar
    _7zz-rar

    nodejs
    nodePackages.npm
    nodePackages.pnpm
  ];
}
