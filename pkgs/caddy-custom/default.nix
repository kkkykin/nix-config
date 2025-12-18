{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "caddy-custom";
  version = "2.10.2-2025-12-18-065747";

  src = fetchTarball {
    url = "https://github.com/kkkykin/custom-caddy/releases/download/v${version}/caddy-linux-amd64.tar.gz";
    sha256 = "1zdh1297swgz42pljbkn8xaz7lm6hzxvpi03aicdsikxflnafqby";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp caddy $out/bin
    chmod +x $out/bin/caddy
  '';

  meta = with lib; {
    description = "Prebuilt custom Caddy binary";
    homepage = "https://github.com/kkkykin/custom-caddy";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "caddy";
  };
}
