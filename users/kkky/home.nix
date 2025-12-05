{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/programs/emacs.nix
  ];
  home.packages = with pkgs; [
    sing-box
  ];

  programs.bash = {
    bashrcExtra = ''
export LIBVIRT_DEFAULT_URI=qemu:///system
'';
  };

}
