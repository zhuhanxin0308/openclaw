# 使用最新版的 Debian Slim Node 镜像 (原生 glibc，兼容性极佳)
FROM node:bookworm-slim

# ==========================================
# 注入从 install.sh 中提取的官方静默安装环境变量
# ==========================================
ENV OPENCLAW_NO_ONBOARD=1 \
    OPENCLAW_NO_PROMPT=1 \
    OPENCLAW_NPM_LOGLEVEL=error \
    SHARP_IGNORE_GLOBAL_LIBVIPS=1

# ==========================================
# 安装系统依赖 (对应脚本中的 install_build_tools_linux)
# ==========================================
# - build-essential, python3, cmake: 应对 llama.cpp 等原生模块的热更新编译
# - curl: 用于健康检查
# - ca-certificates, git: 应对 npm 可能需要从 git 拉取依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    build-essential \
    python3 \
    cmake \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# 核心安装：绕过 bash 脚本，直接执行 npm 安装
# ==========================================
# 既然环境已经就绪，直接用 npm 全局安装是最干净的做法，避免执行安装脚本里多余的 OS 检测逻辑
RUN npm install -g openclaw@latest

# 设置工作目录为官方脚本定义的默认 Workspace
WORKDIR /root/.openclaw

# 复制自定义启动脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 暴露 OpenClaw 端口 (Dashboard)
EXPOSE 18789

# ==========================================
# 极低资源消耗的健康检查
# ==========================================
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:18789/health || exit 1

# 使用 entrypoint 接管 PID 1
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
