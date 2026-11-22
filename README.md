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

大部分服务的加固默认值来自 `pkgs.kkkykin.lib.serviceHardening`，两个仓库的修改需一起使用；
本地 `make build` 会自动 override `../nur-packages`。写入目录和设备例外在服务配置中显式声明。

- sing-box 的运行权限沿用 NixOS 模块及 sing-box 自带 unit，保留 TUN 和跨用户查询；
  专属配置仅增加 `NoNewPrivileges`、严格文件系统写保护、home 保护、私有临时目录和 `0077` umask。
  按进程路由需要上游的 `CAP_SYS_PTRACE`、`CAP_DAC_READ_SEARCH` 和可见的 `/proc`，用于跨用户读取进程的
  `exe`/`fd` 链接及 `0500` 的 fd 目录。配置只读、状态目录隔离和 `ProtectHome` 继续保留。
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

路由字段的权限依赖按 [sing-box 文档](https://sing-box.sagernet.org/configuration/route/rule/) 区分：

| 字段 | Linux 服务所需访问 |
| --- | --- |
| `process_name`、`process_path`、`process_path_regex` | 跨用户查询 socket 对应进程，读取 `/proc/<pid>/exe` 和 fd 目录/链接 |
| `user_id`、`user` | socket 的原始 UID；`user` 还需用户名称解析，通常读取 `/etc/passwd` |
| `interface_address`、`default_interface_address` | 宿主机网卡地址和默认接口监视器；允许 AF_NETLINK，保留宿主机网络 namespace |

sing-box 沿用上游的宿主机 UID、网络、进程和设备访问，未设置通用模板的 namespace 限制，也未限制
AF_NETLINK/AF_UNIX，因此用户名称解析和网卡监视不需要继续放宽文件系统写权限。
`network_type`、`network_interface_address` 和费用/低数据模式字段由 Android/Apple
图形客户端提供，不能通过放宽 Linux 服务权限获得支持。

`tests/sing-box-route-predicates.py` 用回环连接验证上表字段的匹配与不匹配行为：
`python3 tests/sing-box-route-predicates.py`（可通过 `SING_BOX` 指定二进制）。
跨用户查询所需的 capability、进程可见性及沙箱配置由 `tests/sing-box-hardening.nix` 评估；
应用后还需在宿主机验证跨 UID 进程路由。

asus 直接设置 `services.aria2.settings.dir = "/mnt/attach1/downloads"`，aria2 的
下载目录写入白名单随该设置更新，目录属主和组权限由上游 aria2 tmpfiles 规则管理。
aria2 使用 `RequiresMountsFor` 等待来源硬盘挂载；硬盘不可用时服务不能启动，
硬盘的 `nofail` 允许系统继续启动。
