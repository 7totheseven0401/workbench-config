# workbench-config · 团队 Agent 工作台共享配置仓库

> 架构方案 v1.3 §4.3 / 实施第二步。全组统一的 Agent 规范、速查命令与一键接入脚本。

## 新成员接入（目标 10 分钟）

前提（找管理员黄煜炜要两样）：① Tailscale 预授权密钥；② 你的个人 token。

1. 装 Tailscale 并入网：`winget install -e --id Tailscale.Tailscale`（Mac：`brew install --cask tailscale-app`），然后
   `tailscale login --auth-key 预授权密钥`（Mac 打开 Tailscale.app 用密钥登录）；
2. 拿到本仓库（git clone 或解压管理员发的包）；
3. 跑接入脚本：
   - Windows：`powershell -ExecutionPolicy Bypass -File scripts\setup.ps1`
   - Mac：`bash scripts/setup.sh`
   脚本自动识别本机的 Codex / Claude Code，写 MCP 配置、装速查命令、测连通性；
4. **新开终端**，启动你的 Agent，输入 `/产品 通络` 验证——返回 2 条带出处标注即接入成功。

## 目录

```
canon/        规范源文件（唯一事实源）——改规范只改这里
prompts/      速查命令：/产品 /厂商 /清单 /最近变更（Codex 与 Claude Code 通用）
scripts/      build.py（canon → AGENTS.md + CLAUDE.md）· setup.ps1 / setup.sh
AGENTS.md     生成物，Codex 读
CLAUDE.md     生成物，Claude Code 读
```

## 统一规范怎么生效

- **统一版**：把仓库目录作为项目打开时，Codex 自动读 `AGENTS.md`、Claude Code 自动读 `CLAUDE.md`（两者由 build.py 从同一份 canon 生成，口径永远一致）。也可把两文件内容并入你常用项目的对应文件；
- **个人版**：你自己的 `~/.codex/AGENTS.md` / `~/.claude/CLAUDE.md` 会自动叠加在统一版之上，互不冲突；
- **改规范**：改 `canon/` 下的源文件 → `python scripts/build.py` 重新生成 → 提交。**别直接改 AGENTS.md / CLAUDE.md**（会被下次生成覆盖）。

## 日常速查

| 命令 | 作用 |
|---|---|
| `/产品 关键词` | 查产品：名称/型号/分类/厂商/对外报价，带出处 |
| `/厂商 名称` | 查厂商及旗下产品 |
| `/清单 组合名` | 配置组合明细（批 3 数据入库后可用，当前指向浏览页） |
| `/最近变更` | 数据改动记录（第三步写工具上线后有内容） |

不想打字：浏览页 `http://100.127.252.28:8080/`（网内直开，四页签+搜索）。
