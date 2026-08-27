# 团队 Agent 工作台 · 新成员一键接入（Windows）
# 用法：powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
# 前提：已装 Tailscale 并入网（用管理员发的预授权密钥）；手里有管理员发的个人 token。
$ErrorActionPreference = 'Stop'
$URL = 'http://100.127.252.28:8080/mcp'
$root = Split-Path -Parent $PSScriptRoot

Write-Host "=== 团队 Agent 工作台接入 ===" -ForegroundColor Cyan

# 1) token
$token = Read-Host "粘贴管理员发给你的个人 token"
if (-not $token) { Write-Host "未输入 token，退出。" -ForegroundColor Red; exit 1 }
[Environment]::SetEnvironmentVariable('WORKBENCH_TOKEN', $token, 'User')
$env:WORKBENCH_TOKEN = $token
Write-Host "[OK] WORKBENCH_TOKEN 已写入用户环境变量"

# 2) 连通性
$code = & curl.exe -s -o NUL -w "%{http_code}" --max-time 10 -X POST $URL 2>$null
if ($code -ne '401') {
    Write-Host "[警告] 服务器探测异常（HTTP $code，预期 401）。请确认 Tailscale 已登录入网（tailscale status），然后重跑本脚本。" -ForegroundColor Yellow
} else {
    Write-Host "[OK] 服务器连通（401 = 网络通，符合预期）"
}

$found = $false

# 3) Codex
$codexDir = Join-Path $HOME '.codex'
if (Test-Path $codexDir) {
    $found = $true
    $cfg = Join-Path $codexDir 'config.toml'
    $has = (Test-Path $cfg) -and (Select-String -Path $cfg -Pattern 'mcp_servers\.workbench' -Quiet)
    if ($has) {
        Write-Host "[跳过] Codex config.toml 已有 workbench 配置"
    } else {
        Add-Content -Path $cfg -Encoding utf8 -Value "`n[mcp_servers.workbench]`nurl = `"$URL`"`nbearer_token_env_var = `"WORKBENCH_TOKEN`""
        Write-Host "[OK] Codex：workbench 已写入 ~/.codex/config.toml"
    }
    New-Item -ItemType Directory -Force (Join-Path $codexDir 'prompts') | Out-Null
    Copy-Item (Join-Path $root 'prompts\*') (Join-Path $codexDir 'prompts\') -Force
    Write-Host "[OK] Codex：速查命令已装（/产品 /厂商 /清单 /最近变更）"
}

# 4) Claude Code
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $found = $true
    claude mcp remove workbench --scope user 2>$null | Out-Null
    claude mcp add workbench $URL --transport http --scope user --header 'Authorization: Bearer ${WORKBENCH_TOKEN}'
    Write-Host "[OK] Claude Code：workbench 已注册（用户级）"
    New-Item -ItemType Directory -Force (Join-Path $HOME '.claude\commands') | Out-Null
    Copy-Item (Join-Path $root 'prompts\*') (Join-Path $HOME '.claude\commands\') -Force
    Write-Host "[OK] Claude Code：速查命令已装（/产品 /厂商 /清单 /最近变更）"
}

if (-not $found) {
    Write-Host "[错误] 没找到 Codex（~/.codex）也没找到 claude 命令。先装好其中一个再跑本脚本。" -ForegroundColor Red; exit 1
}

Write-Host ""
Write-Host "=== 完成。验证：===" -ForegroundColor Cyan
Write-Host "1. 新开一个终端（老终端读不到刚设的环境变量）"
Write-Host "2. 启动 codex 或 claude，输入：/产品 通络"
Write-Host "3. 预期返回 2 条（通络治疗仪 36000 / 高配版 220000），带出处标注"
Write-Host "浏览页（存书签）：http://100.127.252.28:8080/"
