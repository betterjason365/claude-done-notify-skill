#!/bin/sh
# Claude Code Stop hook：每个回合完成时弹一个系统通知（"回合完成 ✅"）。
# 由 ~/.claude/settings.json 的 hooks.Stop 调用。务必 exit 0，避免阻塞主流程。
#
# 跨平台：macOS 用 terminal-notifier / osascript，Linux 用 notify-send，
# 其它环境退化为终端响铃。

TITLE="Claude"
PROJ=$(basename "${CLAUDE_PROJECT_DIR:-Claude Code}")
MSG="回合完成 ✅"

case "$(uname -s)" in
  Darwin)
    ICON="file:///Applications/Claude.app/Contents/Resources/electron.icns"
    if command -v terminal-notifier >/dev/null 2>&1; then
      terminal-notifier -title "$TITLE" -subtitle "$PROJ" -message "$MSG" \
        -appIcon "$ICON" -group claude-code-stop >/dev/null 2>&1
    else
      osascript -e "display notification \"$MSG\" with title \"$TITLE\" subtitle \"$PROJ\"" >/dev/null 2>&1
    fi
    ;;
  Linux)
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$TITLE — $PROJ" "$MSG" >/dev/null 2>&1
    else
      printf '\a'
    fi
    ;;
  *)
    printf '\a'
    ;;
esac

exit 0
