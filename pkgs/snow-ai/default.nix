{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs
}:

buildNpmPackage rec {
  pname = "snow-ai";
  version = "0.4.26";

  src = fetchFromGitHub {
    owner = "MayDay-wpf";
    repo = "snow-ai";
    rev = "v${version}";
    hash = "sha256-blNvykdBs34v23NrLCmTLWThP4BtYYO05M7B8cJWGd0=";
  };

  npmDepsHash = "sha256-aofEdM4IY40Z7Aop3z0RhIVtG7oCLs6AXUJinQKGgoI=";

  buildPhase = ''
    npm run build
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/snow-ai
    cp -r bundle $out/lib/snow-ai/
    cp -r scripts $out/lib/snow-ai/
    cp package.json $out/lib/snow-ai/

    cat > $out/bin/snow <<EOF
    #!${nodejs}/bin/node
    import('$out/lib/snow-ai/bundle/cli.mjs');
    EOF

    chmod +x $out/bin/snow
  '';

  meta = with lib; {
    description = "Intelligent Command Line Assistant powered by AI";
    homepage = "https://github.com/MayDay-wpf/snow-cli";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "snow";
  };
}
