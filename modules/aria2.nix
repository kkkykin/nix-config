# [[file:../../dotfiles/aria2/20250220T211258--aria2__network.org::#109e43d4-f990-4e01-a20c-916a3c6171d2][module:1]]
{
  config,
  username,
  ...
}: {
  users.users.${username} = {
    extraGroups = ["aria2"];
  };
  systemd.services.aria2 = {
    serviceConfig = {
      WorkingDirectory = "/var/lib/aria2";
    };
  };
  services = {
    aria2 = {
      enable = true;
      rpcSecretFile = config.sops.secrets.aria2_rpc_secret.path;
      serviceUMask = "0002";
      settings = {
        # [[file:../20250220T211258--aria2__network.org::#2847641e-b3b8-4f68-b91c-4a1c6722d88e][save file:1]]
        dir="./downloads";
        disk-cache="64M";
        file-allocation="falloc";
        no-file-allocation-limit="64M";
        continue=true;
        always-resume=false;
        max-resume-failure-tries=0;
        remote-time=true;
        input-file="./aria2.session";
        save-session="./aria2.session";
        save-session-interval=1;
        auto-save-interval=20;
        force-save=false;
        max-file-not-found=10;
        max-tries=0;
        retry-wait=10;
        connect-timeout=10;
        timeout=10;
        max-concurrent-downloads=5;
        max-connection-per-server=16;
        split=32;
        min-split-size="4M";
        piece-length="1M";
        allow-piece-length-change=true;
        lowest-speed-limit=0;
        max-overall-download-limit=0;
        max-download-limit=0;
        http-accept-gzip=true;
        reuse-uri=false;
        allow-overwrite=false;
        auto-file-renaming=true;
        content-disposition-default-utf8=true;
        enable-dht=true;
        enable-dht6=true;
        dht-file-path="./dht.dat";
        dht-file-path6="./dht6.dat";
        dht-entry-point="dht.transmissionbt.com:6881";
        dht-entry-point6="dht.transmissionbt.com:6881";
        bt-enable-lpd=true;
        enable-peer-exchange=true;
        bt-max-peers=128;
        bt-request-peer-speed-limit="10M";
        max-overall-upload-limit="2M";
        max-upload-limit=0;
        seed-ratio=1.0;
        seed-time=0;
        bt-hash-check-seed=true;
        bt-seed-unverified=false;
        bt-tracker="http://1337.abcvg.info:80/announce,http://bt.okmp3.ru:2710/announce,http://echostar.ddnsfree.com:8080/announce,http://ipv4.rer.lol:2710/announce,http://ipv6.rer.lol:6969/announce,http://nyaa.tracker.wf:7777/announce,http://t-backup.213891.xyz:80/announce,http://tk.greedland.net:80/announce,http://torrentsmd.com:8080/announce,http://tracker.beeimg.com:6969/announce,http://tracker.dhitechnical.com:6969/announce,http://tracker.ipv6tracker.ru:80/announce,http://tracker.mywaifu.best:6969/announce,http://tracker.renfei.net:8080/announce,http://www.all4nothin.net:80/announce.php,http://www.wareztorrent.com:80/announce,https://1337.abcvg.info:443/announce,https://t.213891.xyz:443/announce,https://torrent.tracker.durukanbal.com:443/announce,https://tr.abiir.top:443/announce,https://tr.abir.ga:443/announce,https://tr.nyacat.pw:443/announce,https://tracker.alaskantf.com:443/announce,https://tracker.belmult.online:443/announce,https://tracker.foreverpirates.co:443/announce,https://tracker.ghostchu-services.top:443/announce,https://tracker.jdx3.org:443/announce,https://tracker.kuroy.me:443/announce,https://tracker.leechshield.link:443/announce,https://tracker.moeblog.cn:443/announce,https://tracker.uraniumhexafluori.de:443/announce,https://tracker.yemekyedim.com:443/announce,https://tracker.zhuqiy.com:443/announce,https://tracker1.520.jp:443/announce,udp://1c.premierzal.ru:6969/announce,udp://anna.bt.bontal.net:6969/announce,udp://burmese.app:6969/announce,udp://d40969.acod.regrucolo.ru:6969/announce,udp://evan.im:6969/announce,udp://extracker.dahrkael.net:6969/announce,udp://martin-gebhardt.eu:25/announce,udp://open.demonii.com:1337/announce,udp://open.demonoid.ch:6969/announce,udp://open.stealth.si:80/announce,udp://opentor.org:2710/announce,udp://opentracker.io:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://rekcart.duckdns.org:15480/announce,udp://retracker.lanta.me:2710/announce,udp://retracker01-msk-virt.corbina.net:80/announce,udp://t.overflow.biz:6969/announce,udp://torrentclub.online:54123/announce,udp://tr4ck3r.duckdns.org:6969/announce,udp://tracker.bitcoinindia.space:6969/announce,udp://tracker.cloudbase.store:1333/announce,udp://tracker.dler.com:6969/announce,udp://tracker.dler.org:6969/announce,udp://tracker.ducks.party:1984/announce,udp://tracker.filemail.com:6969/announce,udp://tracker.fnix.net:6969/announce,udp://tracker.gmi.gd:6969/announce,udp://tracker.hifitechindia.com:6969/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker.plx.im:6969/announce,udp://tracker.qu.ax:6969/announce,udp://tracker.rescuecrew7.com:1337/announce,udp://tracker.skillindia.site:6969/announce,udp://tracker.srv00.com:6969/announce,udp://tracker.startwork.cv:1337/announce,udp://tracker.torrent.eu.org:451/announce,udp://tracker.torrust-demo.com:6969/announce,udp://tracker.tryhackx.org:6969/announce,udp://tracker.tvunderground.org.ru:3218/announce,udp://tracker.valete.tf:9999/announce,udp://tracker.zupix.online:1333/announce,udp://tracker2.dler.org:80/announce,udp://ttk2.nbaonlineservice.com:6969/announce,udp://udp.tracker.projectk.org:23333/announce,udp://wepzone.net:6969/announce,udp://www.torrent.eu.org:451/announce,udp://yuki.bt.bontal.net:6969/announce,wss://tracker.openwebtorrent.com:443/announce";
        bt-tracker-connect-timeout=10;
        bt-tracker-timeout=10;
        bt-prioritize-piece="head=32M,tail=32M";
        rpc-save-upload-metadata=true;
        follow-torrent=true;
        pause-metadata=false;
        bt-save-metadata=true;
        bt-load-saved-metadata=true;
        bt-remove-unselected-file=true;
        bt-force-encryption=true;
        bt-detach-seed-only=true;
        user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.47";
        peer-agent="Deluge 1.3.15";
        peer-id-prefix="-DE13F0-";
        on-download-stop="scripts/download-stop.py";
        on-download-complete="scripts/download-complete.py";
        on-download-error="scripts/download-error.py";
        on-download-pause="scripts/download-pause.py";
        on-download-start="scripts/download-start.py";
        on-bt-download-complete="scripts/bt-download-complete.py";
        enable-rpc=true;
        rpc-allow-origin-all=true;
        rpc-listen-all=true;
        rpc-listen-port=6800;
        rpc-max-request-size="10M";
        console-log-level="notice";
        quiet=false;
        summary-interval=0;
        show-console-readout=false;
        
      };
    };
  };
}
# module:1 ends here
