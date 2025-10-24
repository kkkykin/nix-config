# 如需全局禁用代理，命令行 make PROXY_OFF=1 ...
PROXY_OFF ?= 0
INPUTS ?=
ifeq ($(PROXY_OFF),1)
  MAYBE_PROXY :=
else
  MAYBE_PROXY := $(if $(all_proxy),,all_proxy=socks5h://127.0.0.1:10807)
endif

# 自动定位本 Makefile 所在的目录
FLAKE_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# 主机名：优先用 _hostname 文件，没有就用 shell hostname
HOSTNAME_FILE := $(FLAKE_DIR)_hostname
HOSTNAME := $(shell \
	if [ -s '$(HOSTNAME_FILE)' ]; then \
		sed '/^[[:space:]]*$$/d; q' '$(HOSTNAME_FILE)' | tr -d '\n'; \
	else \
		hostname; \
	fi)

FLAKE_REF := $(shell printf '%s#%s' '$(FLAKE_DIR)' '$(HOSTNAME)')

# 如果 ../nix-secrets 目录存在，则追加 --override-input 参数
SECRETS_DIR := $(realpath $(FLAKE_DIR)/../nix-secrets)
ifneq ($(wildcard $(SECRETS_DIR)),)
  OVERRIDE_INPUTS := --override-input nix-secrets $(SECRETS_DIR)
else
  OVERRIDE_INPUTS :=
endif

# 默认目标
.PHONY: switch
switch:
	$(MAKE) update-secrets
	sudo $(MAYBE_PROXY) nixos-rebuild --flake $(FLAKE_REF) switch $(if $(SPEC),--specialisation $(SPEC)) $(OVERRIDE_INPUTS)

# 列出所有 generations
.PHONY: list
list:
	$(MAYBE_PROXY) nixos-rebuild --flake $(FLAKE_REF) list-generations

# 其他常用 nixos-rebuild 动作
.PHONY: build test boot dry-run
build test boot dry-run:
	$(MAKE) update-secrets
	$(MAYBE_PROXY) nixos-rebuild --flake $(FLAKE_REF) $@ $(OVERRIDE_INPUTS)

.PHONY: update
update:
	$(MAYBE_PROXY) nix flake update $(INPUTS) --flake $(FLAKE_DIR)

.PHONY: update-secrets
update-secrets:
    $(MAKE) update INPUTS=nix-secrets

# 清理旧系统代 generations（可选）
.PHONY: gc
gc:
	$(MAYBE_PROXY) nix-collect-garbage -d

# 帮助
.PHONY: help
help:
	@echo "Usage: make [PROXY_OFF=1] <target>"
	@echo
	@echo "target:"
	@echo "  switch   (默认) 切换到新配置并激活，可设置 SPEC"
	@echo "  build    仅构建，不激活"
	@echo "  test     构建并进入临时测试环境"
	@echo "  boot     构建并设置下次启动项，不立即切换"
	@echo "  dry-run  仅评估，不构建"
	@echo "  gc       清理旧 generations 和 store"
	@echo
	@echo "环境变量:"
	@echo "  PROXY_OFF=1  禁用默认的 SOCKS5 代理"
