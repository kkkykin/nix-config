{
  username,
  pkgs,
  ...
}: {
  boot.extraModprobeConfig = "options kvm_intel nested=1";
  environment.systemPackages = with pkgs; [
    virtiofsd
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      vhostUserPackages = with pkgs; [
        virtiofsd
      ];
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/263359#issuecomment-1987267279
  networking.firewall.interfaces."virbr*".allowedUDPPorts = [ 53 67 ];

  users.users.${username} = {
    extraGroups = [ "libvirtd" ];
  };
}
