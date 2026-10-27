{pkgs, ...}: let
  eng2zho =
    pkgs.kkkykin.lib.makeStardictDB
    (pkgs.fetchurl {
      url = "https://stardict.uber.space/zh_CN/stardict-langdao-ec-gb-2.4.2.tar.bz2";
      hash = "sha256-aK39Y0hBhyWxgQta7aJQbORN28GtmfL2j2uhNc078Dw=";
    })
    "langdao-eng-zho"
    "stardict-langdao-ec-gb-2.4.2"
    "en_US";
  zho2eng =
    pkgs.kkkykin.lib.makeStardictDB
    (pkgs.fetchurl {
      url = "https://stardict.uber.space/zh_CN/stardict-langdao-ce-gb-2.4.2.tar.bz2";
      hash = "sha256-1Tkjn0kgqjCFgvulORjqFoRLaiN4y3T5uZv67G4vTzA=";
    })
    "langdao-zho-eng"
    "stardict-langdao-ce-gb-2.4.2"
    "zh_CN";
  jpn2zho =
    pkgs.kkkykin.lib.makeStardictDB
    (pkgs.fetchurl {
      url = "https://stardict.uber.space/zh_CN/stardict-XiaoXueTang-jc-2.4.2.tar.bz2";
      hash = "sha256-3/7GTsDoFfW4d4GEirCx+0BKyx1fuxC448prfLnWssU=";
    })
    "xxt-jpn-zho"
    "stardict-XiaoXueTang-jc-2.4.2"
    "ja_JP";
  zho2jpn =
    pkgs.kkkykin.lib.makeStardictDB
    (pkgs.fetchurl {
      url = "https://stardict.uber.space/zh_CN/stardict-XiaoXueTang-cj-2.4.2.tar.bz2";
      hash = "sha256-0kkPImaUC+SGL7by6SteoHS0tcisY54dmTaWmuuh9IQ=";
    })
    "xxt-zho-jpn"
    "stardict-XiaoXueTang-cj-2.4.2"
    "zh_CN";
in {
  services.dico = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 2628;
    DBs = [
      eng2zho
      jpn2zho
      zho2eng
      zho2jpn
    ] ++ (with pkgs.dictdDBs; [
      wordnet
      jpn2eng
      wiktionary
    ]);
  };
}
