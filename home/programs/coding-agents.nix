{
  pkgs,
  ...
}: {
  imports = [
    ./nodejs.nix
  ];
  home.packages = with pkgs;[
    ripgrep
    unstable.codex
    unstable.claude-code
    unstable.claude-code-router
  ];
}
