---
name: claude-done-notify
description: Install/enable a desktop notification that fires every time Claude Code finishes a turn ("回合完成 ✅"). Use when the user wants to set up, install, enable, or fix a turn-complete / done / finished notification for the Claude Code CLI, or asks to be notified when Claude stops.
---

# claude-done-notify — 回合完成桌面通知（安装向导）

这个 skill 帮用户给 **Claude Code CLI** 装上「每个回合完成就弹一个系统通知」的能力。
原理是注册一个 **Stop hook**，调用本目录下的 `notify-stop.sh` 脚本。

> 只针对 Claude Code CLI。它不依赖、也不修改任何 Codex 配置。

## 安装步骤

按顺序执行，每一步做完再做下一步：

1. **确定脚本源路径**：本 skill 目录下的 `notify-stop.sh`（与本 SKILL.md 同级）。

2. **复制脚本到用户 hooks 目录**，并赋可执行权限：
   ```sh
   mkdir -p "$HOME/.claude/hooks"
   cp "<本skill目录>/notify-stop.sh" "$HOME/.claude/hooks/notify-stop.sh"
   chmod +x "$HOME/.claude/hooks/notify-stop.sh"
   ```

3. **在 `~/.claude/settings.json` 注册 Stop hook**。先用 Read 读取该文件（不存在则当作 `{}`）。
   往 `hooks.Stop` 里加入下面这一项；若已存在同样 command 的 Stop hook，则跳过、不要重复添加：
   ```json
   {
     "hooks": {
       "Stop": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "sh /Users/<你>/.claude/hooks/notify-stop.sh"
             }
           ]
         }
       ]
     }
   }
   ```
   注意 `command` 里必须是**绝对路径**（hook 不会展开 `~`），用实际的 `$HOME` 值替换。
   合并时保留 settings.json 里已有的其它字段，不要覆盖。

4. **校验 JSON 合法**：
   ```sh
   python3 -c "import json; json.load(open('$HOME/.claude/settings.json')); print('OK')"
   ```

5. **告知用户生效方式与权限设置**（重要）：
   - settings.json 改动需要**重开一个 Claude Code session** 才会加载。
   - macOS 上若用 `terminal-notifier` 渠道，必须去 **系统设置 → 通知 → terminal-notifier**，
     把「允许通知」打开，否则通知会被系统静默拦截、看不到弹窗。
     （未安装 terminal-notifier 时脚本会退化用 `osascript`，那种情况下需对运行 Claude 的终端 App 开启通知权限。）
   - 想用更好看的图标/分组，建议 `brew install terminal-notifier`。

## 卸载

把 `~/.claude/settings.json` 里那条 Stop hook 删除即可（可选删除 `~/.claude/hooks/notify-stop.sh`）。
