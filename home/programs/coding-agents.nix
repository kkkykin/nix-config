{
  pkgs,
  ...
}: {
  imports = [
    ./nodejs.nix
  ];
  home.packages = with pkgs;[
    ripgrep
    snow-ai
    codex
    claude-code
    claude-code-router
  ];
}
