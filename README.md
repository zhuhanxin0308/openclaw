
# 🦞 OpenClaw Docker Minimal

这是一个为 [OpenClaw](https://openclaw.ai) 深度定制的最小化、高性能 Docker 镜像解决方案。

本项目的核心目标是解决 Node.js CLI 工具在容器化时遇到的“升级即宕机”痛点，实现**无需重启容器即可完成 OpenClaw 核心业务的平滑升级**。

## ✨ 核心特性

* **🤏 极限瘦身**：基于 `node:22-alpine` 构建，仅保留 `make`、`g++`、`python3` 等必须的编译工具链，确保原生 C++ 模块（如 SQLite、Sharp）能完美兼容 `musl` 底层库。
* **🔥 热更新守护 (Hot-Update)**：抛弃传统的应用主进程阻塞模式。使用独立 entrypoint 作为 PID 1 挂起容器，允许在容器内部直接执行 `npm install -g openclaw@latest` 并重启 Daemon，**彻底实现容器零停机升级**。
* **⚡ 极低消耗健康检查**：摒弃了高开销的 CLI 状态探测 (`openclaw daemon status`)，采用原生的 `wget` 对 `18789` 端口进行 HTTP 探测。资源占用骤降，告别 CPU 周期性尖峰。
* **🤖 全自动 CI/CD**：内置 GitHub Actions 流水线，监听代码与 Dockerfile 变更。利用 Docker Buildx 缓存层技术，自动构建多架构镜像并极速推送到 Docker Hub。

## 🚀 快速启动

你可以通过 Docker CLI 直接运行它，建议将 `/root` 目录挂载到宿主机以持久化 OpenClaw 的工作区及配置数据：

```bash
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  -p 3000:3000 \
  -v ./openclaw-data:/root \
  --restart unless-stopped \
  zhuhanxin/openclaw:latest
