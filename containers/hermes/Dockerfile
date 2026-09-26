FROM ubuntu:24.04

RUN apt-get update

RUN apt-get install -y \
      sudo \
      curl \
      ca-certificates \
      gnupg \
      build-essential

RUN apt-get install -y golang-go

# https://github.com/NousResearch/hermes-agent/blob/530d8148aa2f2d7111729d512e39d9e1570e82ce/nix/nixosModules.nix#L143
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --batch --no-tty --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -qq && apt-get install -y -qq nodejs

# Antigravity
RUN curl -fsSL https://antigravity.google/cli/install.sh \
    | bash -s -- --dir /usr/local/bin

# codebuddy
RUN npm install -g @tencent-ai/codebuddy-code

# Claude Code
RUN npm install -g @anthropic-ai/claude-code

# OpenAI Codex CLI
RUN npm install -g @openai/codex

# DeepSeek Harness
RUN npm install -g @deepseek-ai/dsh

RUN rm -rf /var/lib/apt/lists/*

RUN cat >> /etc/profile <<'EOF'
if [ -f /data/.hermes/.env ]; then
    PATH="$(sed -n 's/^PATH=//p' /data/.hermes/.env)"
    export PATH
fi
EOF

RUN touch /var/lib/hermes-tools-provisioned
