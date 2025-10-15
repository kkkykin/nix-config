{
  pkgs,
  ...
}: {
  programs.emacs = {
    package = pkgs.emacs-nox;
    enable = true;
  };
  home.packages = with pkgs;[
    aspell
    aspellDicts.en
    tree-sitter
    gnumake
    gcc
  ];
}
