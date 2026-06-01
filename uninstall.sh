#!/bin/sh
# claude-done-notify 卸载脚本：移除 Stop hook（默认保留脚本文件）。
# 用法：sh uninstall.sh
set -e

HOOK_DST="$HOME/.claude/hooks/notify-stop.sh"
SETTINGS="$HOME/.claude/settings.json"

python3 - "$SETTINGS" "$HOOK_DST" <<'PY'
import json, sys
settings_path, hook_path = sys.argv[1], sys.argv[2]
cmd = "sh %s" % hook_path
try:
    with open(settings_path) as f:
        data = json.load(f)
except (FileNotFoundError, ValueError):
    print("ℹ️  没有可处理的 settings.json。")
    raise SystemExit(0)

stop = data.get("hooks", {}).get("Stop", [])
new_stop = []
for group in stop:
    if isinstance(group, dict):
        group = dict(group)
        group["hooks"] = [h for h in group.get("hooks", []) if h.get("command") != cmd]
        if group["hooks"]:
            new_stop.append(group)
    else:
        new_stop.append(group)

if new_stop:
    data["hooks"]["Stop"] = new_stop
else:
    data.get("hooks", {}).pop("Stop", None)

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
print("✅ 已移除 Stop hook。脚本文件 %s 保留，可手动删除。" % hook_path)
PY

echo "重开一个 Claude Code session 后生效。"
