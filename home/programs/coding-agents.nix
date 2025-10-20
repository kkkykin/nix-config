{
  pkgs,
  ...
}: {
  imports = [
    ./nodejs.nix
  ];
  home.packages = with pkgs;[
    unstable.codex
    unstable.claude-code
    unstable.claude-code-router
  ];
}
