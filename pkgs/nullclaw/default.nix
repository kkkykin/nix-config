{ lib, stdenv, fetchurl }:  
  
stdenv.mkDerivation rec {  
  pname = "nullclaw";  
  version = "2026.3.7";  
  
  src = fetchurl {  
    url = "https://github.com/nullclaw/nullclaw/releases/download/v${version}/nullclaw-linux-x86_64.bin";  
    hash = "sha256-s8okG7LPsiIu2yscHZwPv1C4+oAuaZCS/7vy9m+g+O4=";
  };  
  
  unpackPhase = ''  
    cp $src nullclaw  
  '';  
  
  installPhase = ''  
    runHook preInstall  
    mkdir -p $out/bin  
    mkdir -p $out/share/nullclaw  
  
    # Install binary  
    cp nullclaw $out/bin/nullclaw  
    chmod +x $out/bin/nullclaw  
  
    # Install documentation if available  
    cp README.md $out/share/nullclaw/ 2>/dev/null || true  
    cp LICENSE $out/share/nullclaw/ 2>/dev/null || true  
    runHook postInstall  
  '';  
  
  meta = with lib; {  
    description = "Fastest, smallest, and fully autonomous AI assistant infrastructure written in Zig";  
    homepage = "https://github.com/nullclaw/nullclaw";  
    license = licenses.mit;  
    platforms = [ "x86_64-linux" ];  
    mainProgram = "nullclaw";  
  };  
}
