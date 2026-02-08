{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    python3
  ];
  programs = {
    uv = {
      enable = true;
    };
  };
}
