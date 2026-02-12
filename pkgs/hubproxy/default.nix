{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "hubproxy";
  version = "1.2.3";

  src = fetchTarball {
    url = "https://github.com/sky22333/hubproxy/releases/download/v${version}/hubproxy-v${version}-linux-amd64.tar.gz";
    sha256 = "sha256:0vy2mf14h72nzfipa7v1r73qbqc5h0zax9snsjzzs3b0h0dbhnwj";
  };

  installPhase = ''
    mkdir -p $out/bin

    # Install binary
    cp hubproxy $out/bin/
    chmod +x $out/bin/hubproxy
  '';

  meta = with lib; {
    description = "Docker and GitHub acceleration proxy server";
    homepage = "https://github.com/sky22333/hubproxy";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "hubproxy";
  };
}
