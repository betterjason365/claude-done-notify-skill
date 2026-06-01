# claude-done-notify

给 **Claude Code CLI** 装上「每个回合完成就弹一个系统通知」的能力（`回合完成 ✅`）。

原理是注册一个 Claude Code 的 **Stop hook**，每当 Claude 结束一个回合时调用 `notify-stop.sh` 弹系统通知。仅作用于 Claude Code CLI，不涉及任何 Codex 配置。

跨平台：macOS 用 `terminal-notifier` / `osascript`，Linux 用 `notify-send`，其它环境退化为终端响铃。

---

## 安装

### 方式一：作为 Skill（安装向导）

把 skill 目录放进你的 Claude Code 个人 skills 目录，然后在 Claude Code 里调用它，由它引导完成安装：

```sh
git clone https://github.com/betterjason365/claude-done-notify-skill.git
mkdir -p ~/.claude/skills
cp -r claude-done-notify-skill/skills/claude-done-notify ~/.claude/skills/
```

然后在 Claude Code 会话里输入：

```
/claude-done-notify
```

skill 会把脚本复制到 `~/.claude/hooks/`、在 `~/.claude/settings.json` 注册 Stop hook，并提示你后续的权限设置。

### 方式二：一键脚本（不走 skill）

```sh
git clone https://github.com/betterjason365/claude-done-notify-skill.git
cd claude-done-notify-skill
sh install.sh
```

---

## 生效与权限（重要）

- `settings.json` 改动需要**重开一个 Claude Code session** 才会加载。
- **macOS 必看**：去 **系统设置 → 通知 → terminal-notifier**，把「允许通知」打开，
  否则弹窗会被系统**静默拦截**，你会以为没生效。
  - 未安装 `terminal-notifier` 时，脚本会退化使用 `osascript`，这时需要对**运行 Claude 的终端 App**（Terminal / iTerm 等）开启通知权限。
  - 推荐安装更好看的渠道：`brew install terminal-notifier`

---

## 卸载

```sh
sh uninstall.sh
```

或手动删除 `~/.claude/settings.json` 里那条指向 `notify-stop.sh` 的 Stop hook。

---

## 目录结构

```
claude-done-notify-skill/
├── README.md
├── install.sh                      # 一键安装
├── uninstall.sh                    # 一键卸载
└── skills/
    └── claude-done-notify/
        ├── SKILL.md                # skill 安装向导
        └── notify-stop.sh          # 通知脚本（Stop hook 调用）
```
