{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "picoclaw";
  version = "0.2.0";

  src = fetchTarball {
    url = "https://github.com/sipeed/picoclaw/releases/download/v${version}/picoclaw_Linux_x86_64.tar.gz";
    sha256 = "sha256:1pr4kwwl1w26dqacynzd8v6cfxxfjr4ag8r2s7rca508fkqvcf5b";
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/picoclaw

    # Install binary
    cp picoclaw $out/bin/picoclaw
    chmod +x $out/bin/picoclaw

    # Install documentation if available
    cp README.md $out/share/picoclaw/ 2>/dev/null || true
    cp LICENSE $out/share/picoclaw/ 2>/dev/null || true
  '';

  meta = with lib; {
    description = "A lightweight AI agent framework for CLI automation and multi-platform deployment";
    homepage = "https://github.com/sipeed/picoclaw";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "picoclaw";
  };
}
