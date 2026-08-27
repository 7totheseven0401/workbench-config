# canon/ → 生成 AGENTS.md（Codex 读）+ CLAUDE.md（Claude Code 读），保证两边口径永远一致
# 用法：python scripts/build.py
import pathlib

root = pathlib.Path(__file__).resolve().parent.parent
parts = [p.read_text(encoding="utf-8").strip() for p in sorted((root / "canon").glob("*.md"))]
body = "\n\n---\n\n".join(parts) + "\n"
header = "<!-- 本文件由 scripts/build.py 从 canon/ 生成。改规范只改 canon/，别直接改这里。 -->\n\n"
for name in ("AGENTS.md", "CLAUDE.md"):
    (root / name).write_text(header + body, encoding="utf-8", newline="\n")
    print(f"生成 {name}（{len(parts)} 个 canon 文件）")
