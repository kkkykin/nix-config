{ config, secrets, username, pkgs, lib, ... }:
let
  version = "1.80.8";

  prismaEngines = pkgs.prisma-engines;
  prismaCli = pkgs.prisma;
  py = pkgs.unstable.python3;

  prismaPatched = pkgs.unstable.python3Packages.prisma.overridePythonAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "kkkykin";
      repo = "prisma-client-py";
      rev = "e3d23804414e974558f0035e7faace61bea56cf2";
      hash = "sha256-9/uexdgYsv2S1IRh2SzeV3AO1SEBGPTbKspsEJHPEmw=";
    };
  });

  litellm-otel = py.withPackages (ps: with ps.unstable; [
    prismaPatched
    ps.tomlkit
    ps.opentelemetry-api
    ps.opentelemetry-sdk
    ps.opentelemetry-exporter-otlp

    (ps.litellm.overridePythonAttrs (old: {
      version = version;
      src = pkgs.fetchFromGitHub {
        owner = "BerriAI";
        repo = "litellm";
        rev = "v${version}-stable.1";
        hash = "sha256-oEw18DAAJw0+zD36gp52M+1QbP5IKbAbsOKKTtBC3HQ=";
      };

      patches = (old.patches or []) ++ [
        ./patches/litellm/0001-fix-proxy-migration-ensure-writable.patch
      ];

      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
        prismaCli
        prismaEngines
        pkgs.nodejs
        prismaPatched
        pkgs.python3Packages.pythonRelaxDepsHook
      ];
      pythonRelaxDeps = (old.pythonRelaxDeps or []) ++ [ "grpcio" ];

      postPatch = (old.postPatch or "") + ''
        substituteInPlace litellm/proxy/schema.prisma \
          --replace-fail '  provider = "prisma-client-py"' \
          $'  provider = "prisma-client-py"\n  output = "../../prisma"'
      '';

      postInstall = (old.postInstall or "") + ''
        (
          set -eo pipefail
          export HOME="$TMPDIR"
          export PATH=${prismaPatched}/bin:$PATH

          # make prisma-python + engines consistent
          export PRISMA_VERSION="6.18.0"
          export PRISMA_EXPECTED_ENGINE_VERSION="34b5a692b7bd79939a9a2c3ef97d816e749cda2f"
          export PRISMA_QUERY_ENGINE_BINARY="${prismaEngines}/bin/query-engine"
          export PRISMA_MIGRATION_ENGINE_BINARY="${prismaEngines}/bin/migration-engine"
          export PRISMA_INTROSPECTION_ENGINE_BINARY="${prismaEngines}/bin/introspection-engine"
          export PRISMA_FMT_BINARY="${prismaEngines}/bin/prisma-fmt"

          sp="$out/${ps.python.sitePackages}"
          schema="$sp/litellm/proxy/schema.prisma"

          # generate prisma python client into site-packages/prisma
          mkdir -p "$sp/prisma"
          chmod -R u+w "$sp" || true
          ${prismaCli}/bin/prisma generate --schema "$schema"

          # include litellm_proxy_extras module (repo top-level)
          extras_src="$(find "$NIX_BUILD_TOP" -maxdepth 5 -type d -name litellm_proxy_extras | head -n1 || true)"
          test -n "$extras_src" -a -d "$extras_src"
          cp -a "$extras_src" "$sp/"
        )
      '';

      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ (old.optional-dependencies.proxy or [])
        ++ [
          ps.grpcio
        ];
    }))
  ]);

  url = "http://127.0.0.1:${toString config.services.litellm.port}";
in
{
  # dirs / users
  systemd.tmpfiles.rules = [
    "d /etc/litellm 0750 ${username} litellm -"
  ];

  users.groups.litellm = {};
  users.users.litellm = {
    isSystemUser = true;
    group = "litellm";
    home = "/var/lib/litellm";
    createHome = true;
  };

  # runtime: make prisma/node/openssl available + writable state dir
  systemd.services.litellm = {
    path = [ prismaCli prismaEngines pkgs.nodejs pkgs.openssl ];
    serviceConfig = {
      ExecStart = lib.mkForce
        "${litellm-otel}/bin/litellm --host \"${config.services.litellm.host}\" --port ${toString config.services.litellm.port} --config \"/etc/litellm/config.json\"";
      User = "litellm";
      Group = "litellm";
      DynamicUser = lib.mkForce false;
      PrivateUsers = lib.mkForce false;

      StateDirectory = [ "litellm" "litellm/migrations" ];
      StateDirectoryMode = "0750";
      ReadWritePaths = [ "/var/lib/litellm" ];
    };
  };

  services.litellm = {
    enable = true;
    port = 4000;
    environment = {
      HOME = "/var/lib/litellm";
      PRISMA_HOME_DIR = "/var/lib/litellm";
      LITELLM_MIGRATION_DIR = "/var/lib/litellm/migrations";

      PRISMA_VERSION = "6.18.0";
      PRISMA_EXPECTED_ENGINE_VERSION = "34b5a692b7bd79939a9a2c3ef97d816e749cda2f";
      PRISMA_SCHEMA_ENGINE_BINARY = "${prismaEngines}/bin/schema-engine";
      PRISMA_QUERY_ENGINE_BINARY = "${prismaEngines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY = "${prismaEngines}/lib/libquery_engine.node";
      PRISMA_MIGRATION_ENGINE_BINARY = "${prismaEngines}/bin/migration-engine";
      PRISMA_INTROSPECTION_ENGINE_BINARY = "${prismaEngines}/bin/introspection-engine";
      PRISMA_FMT_BINARY = "${prismaEngines}/bin/prisma-fmt";
    };
    environmentFile = config.sops.secrets.litellm.path;
  };

  # cloudflared
  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress."litellm.${secrets.cloudflared.asus.domain}".service = "http://127.0.0.1:4000";
  };

  services.caddy.virtualHosts."http://litellm.asus.local" = {
    extraConfig = ''
      reverse_proxy ${url}
    '';
  };
}
