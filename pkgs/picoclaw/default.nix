{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "picoclaw";
  version = "0.2.3";

  src = fetchTarball {
    url = "https://github.com/sipeed/picoclaw/releases/download/v${version}/picoclaw_Linux_x86_64.tar.gz";
    sha256 = "sha256:0l0yp27k1f9s3n3b4p45rz4683xgcwcj2qj2ba1v0pkd5nkv17a7";
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
