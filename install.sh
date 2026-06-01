#!/bin/sh
# claude-done-notify 一键安装脚本
# 给 Claude Code CLI 装上「每个回合完成弹系统通知」的 Stop hook。
# 用法：sh install.sh
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SRC="$SCRIPT_DIR/skills/claude-done-notify/notify-stop.sh"
HOOK_DIR="$HOME/.claude/hooks"
HOOK_DST="$HOOK_DIR/notify-stop.sh"
SETTINGS="$HOME/.claude/settings.json"

if [ ! -f "$SRC" ]; then
  echo "❌ 找不到脚本：$SRC" >&2
  exit 1
fi

# 1) 复制脚本
mkdir -p "$HOOK_DIR"
cp "$SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"
echo "✅ 已安装脚本：$HOOK_DST"

# 2) 合并 Stop hook 到 settings.json（用 python3 安全处理 JSON，幂等）
python3 - "$SETTINGS" "$HOOK_DST" <<'PY'
import json, os, sys
settings_path, hook_path = sys.argv[1], sys.argv[2]
cmd = "sh %s" % hook_path

os.makedirs(os.path.dirname(settings_path), exist_ok=True)
try:
    with open(settings_path) as f:
        data = json.load(f)
except (FileNotFoundError, ValueError):
    data = {}

hooks = data.setdefault("hooks", {})
stop = hooks.setdefault("Stop", [])

# 幂等：已存在同 command 就不重复加
exists = any(
    h.get("command") == cmd
    for group in stop if isinstance(group, dict)
    for h in group.get("hooks", []) if isinstance(h, dict)
)
if exists:
    print("ℹ️  Stop hook 已存在，跳过。")
else:
    stop.append({"hooks": [{"type": "command", "command": cmd}]})
    with open(settings_path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("✅ 已在 %s 注册 Stop hook。" % settings_path)
PY

cat <<'EOF'

完成 🎉
- 重开一个 Claude Code session 后生效。
- macOS 提醒：去「系统设置 → 通知 → terminal-notifier」把通知权限打开，
  否则弹窗会被系统静默拦截。未装 terminal-notifier 时脚本退化用 osascript，
  那种情况请对运行 Claude 的终端 App 开启通知权限。
- 建议安装更好看的渠道：brew install terminal-notifier
EOF
