#!/bin/bash
set -Eeuo pipefail

echo "============================================"
echo " Claude Code npm 安装脚本 (AutoDL 兜底版)"
echo "============================================"

if [ -f /etc/network_turbo ]; then
  echo "[1/4] 开启学术网络加速..."
  source /etc/network_turbo
else
  echo "[1/4] 未检测到 /etc/network_turbo，跳过代理设置"
fi

echo "[2/4] 检查 Node.js..."
if ! command -v node >/dev/null 2>&1; then
  echo "未检测到 node，请先安装 Node.js 18+"
  exit 1
fi

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo "Node.js 版本过低: $(node -v)，需要 18+"
  exit 1
fi

echo "Node.js: $(node -v)"
echo "npm: $(npm -v)"

echo "[3/4] 清理 npm 配置，确保 optional 依赖不会被跳过..."
npm config delete omit >/dev/null 2>&1 || true
npm config delete optional >/dev/null 2>&1 || true
npm config set ignore-scripts false

# 关键：Claude Code 的平台二进制依赖 optional deps，国内镜像可能没同步
npm config set registry https://registry.npmjs.org/

echo "registry: $(npm config get registry)"

echo "[4/4] 安装 Claude Code..."
npm install -g @anthropic-ai/claude-code@latest --include=optional --verbose

echo ""
echo "验证安装..."
which -a claude
claude --version
claude doctor || true

echo ""
echo "============================================"
echo " 安装完成!"
echo "============================================"
