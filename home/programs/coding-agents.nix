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
    unstable.codex
    unstable.claude-code
    unstable.claude-code-router
  ];
}
