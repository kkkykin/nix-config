# nix-config

```
flake.nix                 # 主机列表（mkHost）
hosts/<host>/             # 每台主机：硬件、引入哪些服务、主机特有配置
modules/common/           # base（所有主机）、server、wsl、web-apps（my.webApps 辅助选项）
modules/services/         # 各服务的具体配置，按需在 hosts/<host> 中 import
users/                    # 用户配置（原 home-manager 内容已并入 common.nix）
overlays/                 # pkgs.unstable / pkgs.kkkykin 以及补丁
containers/               # hermes-agent 使用的容器镜像
```

- 自定义包与服务模块在 [nur-packages](https://github.com/kkkykin/nur-packages)（input `kkkykin`），
  存在 `../nur-packages` 时 Makefile 会自动 override 为本地版本（`NUR_REMOTE=1` 关闭）。
- 私密配置在 `nix-secrets`（input），存在 `../nix-secrets` 时自动 override。
- 新增局域网服务：在服务模块里写 `my.webApps.<name>.caddyConfig = "reverse_proxy ..."`，
  即得到 `http://<name>.<lanDomain>` 和 cloudflared 隧道 `<name>.<cloudflared.domain>`。
