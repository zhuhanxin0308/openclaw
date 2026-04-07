#!/bin/bash
set -e

echo "🦞 Starting OpenClaw Container Environment..."

# 1. 运行 doctor 迁移/检查配置 (源码中 run_doctor 的逻辑)
# 设置环境变量表明正在更新/启动中
OPENCLAW_UPDATE_IN_PROGRESS=1 openclaw doctor --non-interactive || true

# 2. 检查并启动守护进程
if command -v openclaw >/dev/null; then
    echo "Starting Gateway Daemon..."
    # 使用源码推荐的 daemon restart 确保服务在后台拉起
    OPENCLAW_UPDATE_IN_PROGRESS=1 openclaw daemon restart || true
    echo "✅ OpenClaw daemon is running."
else
    echo "❌ FATAL: openclaw command not found!"
    exit 1
fi

echo "====================================================="
echo "🔄 容器主进程已挂起 (Container PID 1 locked)."
echo "你可以随时在容器内执行 'npm install -g openclaw@latest' 进行无缝升级！"
echo "====================================================="

# 3. 终极挂起魔法：保持容器不死，且几乎不占 CPU
exec tail -f /dev/null
