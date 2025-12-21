{
  secrets,
  ...
}: let
  secret-path = ''
path /unsafe/
path /all/
'';
in {
  services.caddy = {
    virtualHosts = {
      "http://wallpaper.asus.local" = {
          extraConfig = ''
@has_referer {
    header Referer *
}

handle @has_referer {
    respond 403
}

rate_limit {
    zone per_client_ip {
        match {
            path /safe/
            ${secret-path}
        }
        key    static
        events 30
        window 1m
    }
}

@secret {
    ${secret-path}
}

basic_auth @secret {
	alice $2a$14$9ai3XfaXmtCFba4k61EeRuxUYzZ62OaIv7kSraVeUmI8DIiB8KPEy
}

handle_path /safe/ {
	random_file {
		root /mnt/mediadata/wallpaper
		include **
		exclude Voice_of_Shadow/*
		cache 1h
	}
}

handle_path /unsafe/ {
	random_file {
		root /mnt/mediadata/wallpaper/Voice_of_Shadow
		include **
		cache 1h
	}
}

handle_path /all/ {
	random_file {
		root /mnt/mediadata/wallpaper
		include **
		cache 1h
	}
}
'';
      };
    };
  };

  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "wallpaper.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "wallpaper.asus.local";
        };
      };
    };
  };
}
