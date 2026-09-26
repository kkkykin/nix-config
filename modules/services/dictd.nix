{ lib, pkgs, ... }:

let
  makeDictdDB =
    src: name: subdir: locale:
    pkgs.stdenv.mkDerivation {
      name = "dictd-db-${name}";
      inherit src;

      locale = locale;
      dbName = name;

      dontBuild = true;

      unpackPhase = ''
        tar xf ${src}
      '';

      installPhase = ''
        mkdir -p $out/share/dictd
        cp $(ls ./${subdir}/*.{dict*,index} || true) \
           $out/share/dictd
        echo "${locale}" > $out/share/dictd/locale
      '';

      meta = {
        description = "Custom dictd dictionary: ${name}";
        platforms = lib.platforms.linux;
      };
    };

  eng2zho = makeDictdDB
    (pkgs.fetchurl {
      url = "https://download.freedict.org/dictionaries/eng-zho/2025.11.23/freedict-eng-zho-2025.11.23.dictd.tar.xz";
      sha256 = "sha256-uLYsQhFQP7dv/dS8WGIqsQL7z6SfJMnBupTtbRTt4zA=";
    })
    "eng-zho"
    "eng-zho"
    "en_US";
in
{
  services.dictd = {
    enable = true;

    DBs =
      with pkgs.dictdDBs; [
        eng2zho
      ] ++ [
        jpn2eng
        wordnet
        eng2jpn
        wiktionary
      ];
  };
}
