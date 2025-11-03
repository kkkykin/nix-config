{
  username,
  pkgs,
  ...
}: {
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
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  users.users.${username} = {
    extraGroups = [ "libvirtd" ];
  };
}
