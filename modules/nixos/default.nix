{
  all-services = import ./all-services.nix;
  aria2 = import ./aria2.nix;
  cloudflared = import ./cloudflared.nix;
  fdroid = import ./fdroid.nix;
  freshrss = import ./freshrss.nix;
  jellyfin = import ./jellyfin.nix;
  kavita = import ./kavita.nix;
  komga = import ./komga.nix;
  libvirt = import ./libvirt.nix;
  nixpkgs = import ./nixpkgs.nix;
  server = import ./server.nix;
  sing-box = import ./sing-box.nix;
  system = import ./system.nix;
  tcpdump = import ./tcpdump.nix;
  wsl = import ./wsl.nix;
}
