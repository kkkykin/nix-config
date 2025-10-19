{
  pkgs,
  ...
}: {
  programs.emacs = {
    package = pkgs.emacs-nox;
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-ts-mode
      epkgs.eat
      epkgs.denote
    ];
  };
  home.packages = with pkgs;[
    aspell
    aspellDicts.en
    tree-sitter
    gnumake
    gcc
  ];
}
