{
  pkgs,
  ...
}: {
  imports = [
    ./nodejs.nix
  ];
  home.packages = with pkgs;[
    ripgrep
    unstable.codex-acp
    # kkkykin.snow-ai
    # codex
    # claude-code
    # claude-code-router
  ];
}
