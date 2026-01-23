{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "cli-proxy-api";
  version = "6.7.11";

  src = fetchTarball {
    url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_amd64.tar.gz";
    sha256 = "sha256:1fcrbqc4zlmw55g070qqa0339drw11hrj28x5acgrx6jad8xw5ag";
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/cliproxyapi

    # 安装二进制文件
    cp cli-proxy-api $out/bin/
    chmod +x $out/bin/cli-proxy-api

    # 安装配置文件和文档
    cp config.example.yaml $out/share/cliproxyapi/
    cp README.md $out/share/cliproxyapi/
    cp README_CN.md $out/share/cliproxyapi/
    cp LICENSE $out/share/cliproxyapi/
  '';

  meta = with lib; {
    description = "A proxy server that provides OpenAI/Gemini/Claude/Codex compatible API interfaces for CLI";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "cli-proxy-api";
  };
}
