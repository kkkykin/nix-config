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

服务加固默认值来自 `pkgs.kkkykin.lib.serviceHardening`，两个仓库的修改需一起使用；
本地 `make build` 会自动 override `../nur-packages`。写入目录和设备例外在服务配置中显式声明。

- sing-box 保留 TUN 所需的网络 capabilities 和 `/dev/net/tun`；不再继承 ptrace 和 DAC 读取绕过能力。
- NapCat WebUI 仅在 `127.0.0.1:6099` 发布，可通过 SSH 转发访问；OneBot 保留跨主机访问。
- Calibre 后端仅监听回环，局域网通过 `http://calibre.<lanDomain>` 访问，不自动添加公网隧道。
- Hermes 因本机代理/API 保留 host 网络和容器内 sudo，但移除 raw socket、设备创建及设置 file capabilities 的能力。
- music-sync 由 systemd 挂载 X7MUSIC，使用独立用户同步，源目录只读；挂载在没有服务依赖时自动卸载。

部署后需验证 TUN 路由、aria2 hooks、QQ 登录/桥接、GPU 浏览器和音乐同步。
基础加固保留 JIT 支持；完整的 `confinement` 需逐服务确认运行时文件和 secret 映射后另行启用。
