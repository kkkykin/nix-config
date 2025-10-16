{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/programs/emacs.nix
  ];
  home.packages = with pkgs; [
    unstable.sing-box
  ];

  programs.git = {
    userName = "kkky";
    userEmail = "kkkykin@foxmail.com";
  };
}
