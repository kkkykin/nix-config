{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "caddy-custom";
  version = "2.11.4-2026-07-17-004050";

  src = fetchTarball {
    url = "https://github.com/kkkykin/custom-caddy/releases/download/v${version}/caddy-linux-amd64.tar.gz";
    sha256 = "sha256:0kwjrxkrp7sp0swpha1yq62x5qj1p6iny2arbidx4ph0p7cz8h4m";
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
