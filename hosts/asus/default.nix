# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/system.nix
    ../../modules/server.nix
    ../../modules/nixpkgs.nix
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/swap".options = [ "noatime" ];
    "/mnt/mediadata" = {
      label = "mediadata";
      fsType = "btrfs";
      options = [ "compress=zstd" "nofail" "users" "exec" ];
    };
    "/mnt/attach1" = {
      label = "attach1";
      fsType = "btrfs";
      options = [ "compress=zstd" "nofail" "users" ];
    };

    "/mnt/attach2" = {
      label = "attach2";
      fsType = "btrfs";
      options = [ "compress=zstd" "nofail" "user" "noauto" ];
    };

    "/mnt/x7music" = {
      label = "X7MUSIC";
      fsType = "vfat";
      options = [ "nofail" "user" "noauto" ];
    };
  };
  swapDevices = [{ 
    device = "/swap/swapfile"; 
    size = 8*1024; # Creates an 8GB swap file 
  }];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
