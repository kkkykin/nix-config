{
  config,
  lib,
  pkgs,
  ...
}: let
  # WordNet's index preserves case and punctuation without declaring them.
  # Normalize its search keys so dictd's binary search can find every entry.
  wordnetDB =
    pkgs.runCommand "dictd-db-wordnet" {
      nativeBuildInputs = [pkgs.dict];
      dbName = "wordnet";
      locale = "en_US.UTF-8";
      inherit (pkgs.dictdDBs.wordnet) meta;
    } ''
      mkdir -p $out/share/dictd
      ln -s ${pkgs.dictdDBs.wordnet}/share/dictd/wn.dict $out/share/dictd/wn.dict
      cp ${pkgs.dictdDBs.wordnet}/share/dictd/locale $out/share/dictd/locale
      awk -F '\t' '$1 !~ /^00-database-/' \
        ${pkgs.dictdDBs.wordnet}/share/dictd/wn.index > words.index
      dictfmt -I --index-keep-orig --quiet \
        < words.index > normalized.index
      # Keep the metadata keys verbatim, pointing to their existing articles.
      awk -F '\t' '$1 ~ /^00-database-/' \
        ${pkgs.dictdDBs.wordnet}/share/dictd/wn.index >> normalized.index
      LC_ALL=C sort -s -d -t $'\t' -k1,1 normalized.index > $out/share/dictd/wn.index
    '';
in {
  # Inflection aliases are already in the primary index. Extra word/suffix
  # indexes increase memory use and their collector commands mishandle locale.
  nixpkgs.overlays = [
    (_final: prev: {
      dictDBCollector = args:
        (prev.dictDBCollector args).overrideAttrs (old: {
          installPhase = lib.concatStringsSep "\n" (lib.filter
            (line:
              !(lib.any (marker: lib.hasInfix marker line) [
                "dictfmt_index2word"
                "dictfmt_index2suffix"
                "index_word "
                "index_suffix "
                "export LC_ALL="
                "export LANG="
              ]))
            (lib.splitString "\n" old.installPhase));
        });
    })
  ];

  services.dictd = {
    enable = true;

    # The dictd collector uses package.name as the protocol database name.
    DBs =
      map (db:
        db // {name = db.dbName or (lib.removePrefix "dict-db-" (lib.getName db));})
      (
        (import ./dict-databases.nix {inherit pkgs;})
        ++ (with pkgs.dictdDBs; [
          wordnetDB
          # Keep the full Wiktionary disabled on this host with 1 GiB of RAM.
          # wiktionary
        ])
      );
  };
}
