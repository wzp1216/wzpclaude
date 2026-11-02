---
name: claudeskill-repo
description: ~/.claude/skills 已原地 git 化并推送到 github.com/wzp1216/claudeskill，更新 skill 直接 commit+push
metadata: 
  node_type: memory
  type: project
  originSessionId: 7f0679b1-cb7c-4129-b321-ccdaeb4dc71a
---

`~/.claude/skills/` 目录本身就是一个 git 仓库（2026-08-31 建立，文件原地不动、无任何副本），远程为 `git@github.com:wzp1216/claudeskill.git`，分支 `main`。包含 4 个 skills：`academic-pptx`、`academic-pptx-zh`、`pptx`、`ubuntu-system-check`。

**Why:** 用户明确要求 skill 不要复制进 wzpclaude 仓库再推送，而是原地版本化。

**How to apply:** 更新 skill 时直接在 `~/.claude/skills` 里 commit + push（提交信息用中文）。wzpclaude 仓库中的 skills 副本已全部清除（2026-08-31），wzpclaude 只保留文档类内容。迁移 skill 时注意修正 SKILL.md 内硬编码的绝对路径。
