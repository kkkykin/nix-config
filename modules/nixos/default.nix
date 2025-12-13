{
  all-services = import ./all-services.nix;
  aria2 = import ./aria2.nix;
  axonhub = import ./axonhub.nix;
  cli-proxy-api = import ./cli-proxy-api.nix;
  cloudflared = import ./cloudflared.nix;
  fdroid = import ./fdroid.nix;
  freshrss = import ./freshrss.nix;
  gpt-load = import ./gpt-load.nix;
  jellyfin = import ./jellyfin.nix;
  kavita = import ./kavita.nix;
  komga = import ./komga.nix;
  libvirt = import ./libvirt.nix;
  litellm = import ./litellm.nix;
  music-sync = import ./music-sync.nix;
  nixpkgs = import ./nixpkgs.nix;
  openlist = import ./openlist.nix;
  server = import ./server.nix;
  sillytavern = import ./sillytavern.nix;
  sing-box = import ./sing-box.nix;
  system = import ./system.nix;
  tcpdump = import ./tcpdump.nix;
  uni-api = import ./uni-api.nix;
  wsl = import ./wsl.nix;
}
