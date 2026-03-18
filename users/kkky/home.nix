{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/programs/emacs.nix
    ../../home/programs/coding-agents.nix
  ];
  home.packages = with pkgs; [
    sing-box
    kkkykin.montecarlo-ip-searcher
  ];

  programs.bash = {
    bashrcExtra = ''
export LIBVIRT_DEFAULT_URI=qemu:///system
'';
  };

}
