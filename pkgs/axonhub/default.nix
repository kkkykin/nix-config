{ lib
, stdenv
, fetchzip
, version ? "0.5.10"
}:

let
  # Map Nix platform strings to GitHub release asset names
  platform = with stdenv;
    if isLinux then
      if isx86_64 then "linux_amd64"
      else if isAarch64 then "linux_arm64"
      else throw "Unsupported Linux platform: ${system}"
    else if isDarwin then
      if isx86_64 then "darwin_amd64"
      else if isAarch64 then "darwin_arm64"
      else throw "Unsupported Darwin platform: ${system}"
    else throw "Unsupported platform: ${system}";

  # SHA256 hashes for each platform (fill these in using method described below)
  hashes = {
    x86_64-linux   = "sha256-wmpqzVJlef237X9Az7yXNmRXQg8/KNf4L/irRknWwOg=";
    aarch64-linux  = "0000000000000000000000000000000000000000000000000000000000000000";
    x86_64-darwin  = "0000000000000000000000000000000000000000000000000000000000000000";
    aarch64-darwin = "0000000000000000000000000000000000000000000000000000000000000000";
  };

in
stdenv.mkDerivation {
  pname = "axonhub";
  inherit version;

  src = fetchzip {
    url = "https://github.com/looplj/axonhub/releases/download/v${version}/axonhub_${version}_${platform}.zip";
    sha256 = hashes.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");
    stripRoot = false;
  };

  # No build phase needed - binary is pre-compiled
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    cp axonhub $out/bin/
    chmod +x $out/bin/axonhub
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "AI Gateway and Model Hub for managing and routing to various AI providers";
    homepage = "https://github.com/looplj/axonhub";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "axonhub";
  };
}
