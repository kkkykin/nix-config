# Converted dictionaries shared by the Dico and dictd service modules.
{pkgs}: let
  makeDictdDB = pkgs.kkkykin.lib.makeDictdDB;
in [
  (makeDictdDB {
    src = pkgs.fetchurl {
      url = "https://stardict.uber.space/zh_CN/stardict-langdao-ec-gb-2.4.2.tar.bz2";
      hash = "sha256-aK39Y0hBhyWxgQta7aJQbORN28GtmfL2j2uhNc078Dw=";
    };
    dbName = "langdao-eng-zho";
    inputFile = "stardict-langdao-ec-gb-2.4.2/langdao-ec-gb.ifo";
    languages = ["en"];
  })
  (makeDictdDB {
    src = pkgs.fetchurl {
      url = "https://stardict.uber.space/zh_CN/stardict-XiaoXueTang-jc-2.4.2.tar.bz2";
      hash = "sha256-3/7GTsDoFfW4d4GEirCx+0BKyx1fuxC448prfLnWssU=";
    };
    dbName = "xxt-jpn-zho";
    inputFile = "stardict-XiaoXueTang-jc-2.4.2/XiaoXueTang-jc.ifo";
    languages = ["ja"];
  })
  (makeDictdDB {
    src = pkgs.fetchurl {
      url = "https://stardict.uber.space/zh_CN/stardict-langdao-ce-gb-2.4.2.tar.bz2";
      hash = "sha256-1Tkjn0kgqjCFgvulORjqFoRLaiN4y3T5uZv67G4vTzA=";
    };
    dbName = "langdao-zho-eng";
    inputFile = "stardict-langdao-ce-gb-2.4.2/langdao-ce-gb.ifo";
    languages = [];
  })
  (makeDictdDB {
    src = pkgs.fetchurl {
      url = "https://stardict.uber.space/zh_CN/stardict-XiaoXueTang-cj-2.4.2.tar.bz2";
      hash = "sha256-0kkPImaUC+SGL7by6SteoHS0tcisY54dmTaWmuuh9IQ=";
    };
    dbName = "xxt-zho-jpn";
    inputFile = "stardict-XiaoXueTang-cj-2.4.2/XiaoXueTang-cj.ifo";
    languages = [];
  })
]
