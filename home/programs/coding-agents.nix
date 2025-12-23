{
  pkgs,
  ...
}: {
  imports = [
    ./nodejs.nix
  ];
  home.packages = with pkgs;[
    ripgrep
    # kkkykin.snow-ai
    # codex
    # claude-code
    # claude-code-router
  ];
}
