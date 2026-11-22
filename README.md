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

sing-box 的 `/etc/sing-box` 保持只读，`../s-dotfiles` 部署时将托管文件设为
`0640`、属组设为 `sing-box`，配置目录为 `2750`，部署用户需属于 `sing-box` 组。
Linux 生成配置的 cache、dashboard 和 Tailscale 状态使用相对路径，由服务的
`-D /var/lib/sing-box` 写入 systemd 管理的 `0700` 状态目录。asus 直接读取
`/etc/sing-box/client/500-tun.json`，无需根目录的 `500-tun.json` 软链接。
其他主机可通过 `my.sing-box.configFiles` 列出所需文件；服务端应只选择公共 main、DNS
及本机的 `500-s0.json` 或 `500-s2.json`，空列表继续兼容原先的根目录布局。

首次迁移前先停止服务，将旧状态复制到新位置；下面只复制目标尚不存在的项，保留旧文件。
已有目标需要先核对，尤其是 Tailscale 身份，不能用旧数据覆盖正在使用的状态。

```sh
sudo systemctl stop sing-box
sudo install -d -m 0700 -o sing-box -g sing-box /var/lib/sing-box
for name in cache.db dashboard tailscale_state; do
  if sudo test -e "/etc/sing-box/$name" && ! sudo test -e "/var/lib/sing-box/$name"; then
    sudo cp -a --no-preserve=ownership -- "/etc/sing-box/$name" "/var/lib/sing-box/$name"
    sudo chown -R --no-dereference sing-box:sing-box "/var/lib/sing-box/$name"
  fi
done
```

然后在 `s-dotfiles` 执行 `make deploy-sing-box USE_SECRETS=1` 重新部署配置，再在本仓库
应用新配置并重启 sing-box。asus 的服务不再加载旧的根目录配置软链接，旧链接可之后手动删除。
