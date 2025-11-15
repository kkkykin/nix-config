{ lib, buildGoModule, buildNpmPackage, fetchFromGitHub }:

let
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "tbphp";
    repo = "gpt-load";
    rev = "v${version}";
    sha256 = "1p21jqfhxl0hhai5rv4w947lhgs4x2jsa169whd4d9dhrf86c8wz";
  };

  # 前端构建
  frontend = buildNpmPackage {
    pname = "gpt-load-frontend";
    inherit version src;

    sourceRoot = "${src.name}/web";

    npmDepsHash = "sha256-BqnVCjPYDpr82Ky6lJ40+s+HDajxa8nOD1Y5S3mXmO0=";

    npmBuildScript = "build";

    env = {
      VITE_VERSION = version;
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/gpt-load-frontend
      cp -r dist/* $out/lib/gpt-load-frontend/
      runHook postInstall
    '';
  };

  # 后端构建
  backend = buildGoModule {
    pname = "gpt-load-backend";
    inherit version src;

    vendorHash = "sha256-6YFmDiMhlGtrg4WW6nKmk2JMc9OufMe4qsZ8l/2SjwU=";

    ldflags = [
      "-s"
      "-w"
      "-X gpt-load/internal/version.Version=${version}"
    ];

    env = {
      CGO_ENABLED = 0;
      GOPROXY = "https://goproxy.cn,direct";
    };

    # 后端需要前端资源嵌入
    preBuild = ''
      mkdir -p web/dist
      cp -r ${frontend}/lib/gpt-load-frontend/* web/dist/
    '';
  };

in buildGoModule {
  pname = "gpt-load";
  inherit version src;

  vendorHash = backend.vendorHash;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/gpt-load
    ln -s ${backend}/bin/gpt-load $out/bin/gpt-load
    ln -s ${frontend}/lib/gpt-load-frontend $out/lib/gpt-load/frontend

    runHook postInstall
  '';

  meta = with lib; {
    description = "高性能、企业级的 AI 接口透明代理服务";
    homepage = "https://github.com/tbphp/gpt-load";
    license = licenses.mit;
    maintainers = [ ];
  };
}
