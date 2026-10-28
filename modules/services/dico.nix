{pkgs, ...}: {
  services.dico = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 2628;
    DBs =
      (import ./dict-databases.nix {inherit pkgs;})
      ++ (with pkgs.dictdDBs; [
        wordnet
        jpn2eng
        # Dico's dictorg backend needs about 1.7 GiB to load the full Wiktionary.
        # Keep it disabled on this host with 1 GiB of RAM.
        # wiktionary
      ]);
  };

  systemd.services.dico.serviceConfig = {
    CPUQuota = "50%";
    MemoryMax = "384M";
    MemorySwapMax = "0";
    RestartSec = "10s";
  };
}
