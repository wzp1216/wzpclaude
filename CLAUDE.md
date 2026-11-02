# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库定位

wzpclaude 是万志平个人工作区（本机根目录 `/media/data/claudewzp/`）中存放 **Claude Code 配置与使用文档** 的子项目。纯文档仓库：没有代码、构建、测试或 lint，无 package.json / requirements.txt 之类依赖文件。

| 文件 | 内容 |
|------|------|
| `claudewzp.md` | 可移植的个人全局配置：工作方式四原则、角色模板（A 代码 / B 公文 / C 学术）、Python 环境约定、工作区项目总览。**本仓库的行为准则来源** |
| `claude-code-guide.md` | Claude Code CLI 使用教程（用户编写的参考手册） |
| `linuxcmd.md` | Linux 常用命令速查手册 |
| `.claude/skills/` | 空目录（占位）。技能已迁至独立仓库 `~/.claude/skills`（git@github.com:wzp1216/claudeskill.git） |
| `claude-share/` | 跨机器共享的 Claude 配置包：`settings.example.json`（脱敏设置模板）+ `memory/`（精选关键记忆快照）+ `README.md`（同步步骤） |

## 工作方式总则

进入本仓库工作前**先通读 `claudewzp.md`**（该文件第六章约定：进入任何子项目先读其 CLAUDE.md）。要点：

- **四条原则**：先思考后编码；简单优先；外科手术式修改（不顺手改进无关内容）；目标驱动执行。
- **角色模板优先**：子项目 CLAUDE.md 与角色模板冲突时，以 `claudewzp.md` 中的角色模板为准。本仓库的维护任务通常不属于 A/B/C 任何一类，按通用原则即可。
- **语言**：所有文档、注释、提交信息用中文。
- **Git 提交信息**：`docs: 更新XXX文档` / `feat: 新增XXX功能` / `fix: 修复XXX问题`（本仓库历史上以 `docs:` 为主）。

## 架构与跨文件关联（读多个文件才能看清的部分）

1. **`claudewzp.md` 的可移植性是硬要求**：该文件设计为复制到新电脑即可用（重命名 `~/.claude/CLAUDE.md` 或会话中 `@claudewzp.md` 引用）。编辑时保持这一属性：通用约定写进它，仅本机有效的路径/环境备注要明确标注（如现有"本机缺少 python3-venv"的注）。
2. **工作区总览与实际状态可能不一致**：工作区根已迁至 `/media/data/claudewzp/`（`~/data` 为指向它的软链，`~/claudewzp/` 已不存在）。`claudewzp.md` 第五章的兄弟项目总览反映大方向，引用具体路径前先 `ls` 确认存在，不要把总览表当作当前真实目录结构。
3. **技能已迁出本仓库**：本仓库 `.claude/skills/` 为空目录（占位）；4 个技能（academic-pptx / academic-pptx-zh / pptx / ubuntu-system-check）源文件在 `~/.claude/skills/`，该目录本身是独立 git 仓库（git@github.com:wzp1216/claudeskill.git），更新技能在其中 commit+push，勿再复制回本仓库。ubuntu-system-check 核心流程：sudo 预授权（`echo '<密码>' | sudo -S -v` 缓存凭据）→ 只读检查 → 报告（✅/⚠️/❌）→ 维护动作逐项经用户确认（默认移入回收站而非 rm）。
4. **文档间有内容重叠**：`claudewzp.md` 与 `claude-code-guide.md` 都涉及 CLAUDE.md / skills / memory 配置体系。修改其中一处的约定时，检查另一处是否需同步（如新增技能后更新 `claudewzp.md` 末尾的"配套文件"说明）。
5. **`claude-share/` 是记忆与设置的手动快照**：记忆的实时副本在 `~/.claude/projects/*/memory/`（Claude 按项目自动加载），`claude-share/memory/` 是 2026-11-03 导出的共享快照；本机记忆有值得共享的更新后手动同步到该目录再 commit+push（详见 `claude-share/README.md`），勿反向用旧快照覆盖本机记忆。settings 模板已脱敏，任何密钥不得进入本仓库。
6. **优先级链条**：本文件（wzpclaude 的 CLAUDE.md）< 角色模板（`claudewzp.md`）< 各兄弟项目自己的 CLAUDE.md（仅对各自项目生效）。跨项目任务时，先读目标项目的 CLAUDE.md。

## 常用命令

```bash
git add -A && git commit -m "docs: 更新XXX文档"   # 中文提交信息
```

无构建、测试、lint 命令。验证文档修改的唯一方式是通读上下文确认一致性。
