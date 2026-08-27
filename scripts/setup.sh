#!/bin/bash
# 团队 Agent 工作台 · 新成员一键接入（macOS / Linux）
# 用法：bash scripts/setup.sh
# 前提：已装 Tailscale 并入网；手里有管理员发的个人 token。
set -e
URL='http://100.127.252.28:8080/mcp'
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== 团队 Agent 工作台接入 ==="

# 1) token
read -r -p "粘贴管理员发给你的个人 token: " TOKEN
[ -z "$TOKEN" ] && { echo "未输入 token，退出。"; exit 1; }
RC="$HOME/.zshrc"; [ -n "$BASH_VERSION" ] && [ ! -f "$HOME/.zshrc" ] && RC="$HOME/.bashrc"
grep -v '^export WORKBENCH_TOKEN=' "$RC" 2>/dev/null > "$RC.tmp" || true
mv "$RC.tmp" "$RC"
echo "export WORKBENCH_TOKEN='$TOKEN'" >> "$RC"
export WORKBENCH_TOKEN="$TOKEN"
echo "[OK] WORKBENCH_TOKEN 已写入 $RC"

# 2) 连通性
CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 -X POST "$URL" || true)
if [ "$CODE" = "401" ]; then
  echo "[OK] 服务器连通（401 = 网络通，符合预期）"
else
  echo "[警告] 服务器探测异常（HTTP $CODE，预期 401）。确认 Tailscale 已登录入网后重跑本脚本。"
fi

FOUND=0

# 3) Codex
if [ -d "$HOME/.codex" ]; then
  FOUND=1
  CFG="$HOME/.codex/config.toml"
  if grep -q 'mcp_servers\.workbench' "$CFG" 2>/dev/null; then
    echo "[跳过] Codex config.toml 已有 workbench 配置"
  else
    printf '\n[mcp_servers.workbench]\nurl = "%s"\nbearer_token_env_var = "WORKBENCH_TOKEN"\n' "$URL" >> "$CFG"
    echo "[OK] Codex：workbench 已写入 ~/.codex/config.toml"
  fi
  mkdir -p "$HOME/.codex/prompts"
  cp "$ROOT/prompts/"* "$HOME/.codex/prompts/"
  echo "[OK] Codex：速查命令已装"
fi

# 4) Claude Code
if command -v claude >/dev/null 2>&1; then
  FOUND=1
  claude mcp remove workbench --scope user >/dev/null 2>&1 || true
  claude mcp add workbench "$URL" --transport http --scope user --header 'Authorization: Bearer ${WORKBENCH_TOKEN}'
  echo "[OK] Claude Code：workbench 已注册（用户级）"
  mkdir -p "$HOME/.claude/commands"
  cp "$ROOT/prompts/"* "$HOME/.claude/commands/"
  echo "[OK] Claude Code：速查命令已装"
fi

[ "$FOUND" = 0 ] && { echo "[错误] 没找到 Codex（~/.codex）也没找到 claude 命令。"; exit 1; }

echo ""
echo "=== 完成。验证：==="
echo "1. 新开一个终端；2. 启动 codex 或 claude，输入：/产品 通络"
echo "3. 预期返回 2 条（通络治疗仪 36000 / 高配版 220000），带出处标注"
echo "浏览页（存书签）：http://100.127.252.28:8080/"
