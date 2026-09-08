# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库定位

wzpclaude 是万志平个人工作区（`~/claudewzp/`）中存放 **Claude Code 配置与使用文档** 的子项目。纯文档仓库：没有代码、构建、测试或 lint，无 package.json / requirements.txt 之类依赖文件。

| 文件 | 内容 |
|------|------|
| `claudewzp.md` | 可移植的个人全局配置：工作方式四原则、角色模板（A 代码 / B 公文 / C 学术）、Python 环境约定、工作区项目总览。**本仓库的行为准则来源** |
| `claude-code-guide.md` | Claude Code CLI 使用教程（用户编写的参考手册） |
| `linuxcmd.md` | Linux 常用命令速查手册 |
| `.claude/skills/ubuntu-system-check/` | 项目技能：Ubuntu 系统检查与维护 |

## 工作方式总则

进入本仓库工作前**先通读 `claudewzp.md`**（该文件第六章约定：进入任何子项目先读其 CLAUDE.md）。要点：

- **四条原则**：先思考后编码；简单优先；外科手术式修改（不顺手改进无关内容）；目标驱动执行。
- **角色模板优先**：子项目 CLAUDE.md 与角色模板冲突时，以 `claudewzp.md` 中的角色模板为准。本仓库的维护任务通常不属于 A/B/C 任何一类，按通用原则即可。
- **语言**：所有文档、注释、提交信息用中文。
- **Git 提交信息**：`docs: 更新XXX文档` / `feat: 新增XXX功能` / `fix: 修复XXX问题`（本仓库历史上以 `docs:` 为主）。

## 架构与跨文件关联（读多个文件才能看清的部分）

1. **`claudewzp.md` 的可移植性是硬要求**：该文件设计为复制到新电脑即可用（重命名 `~/.claude/CLAUDE.md` 或会话中 `@claudewzp.md` 引用）。编辑时保持这一属性：通用约定写进它，仅本机有效的路径/环境备注要明确标注（如现有"本机缺少 python3-venv"的注）。
2. **工作区总览与实际状态不一致**：`claudewzp.md` 第五章列出的兄弟项目（check_system_onehour、self-study、class-project、paper-AI、jiaowuzhidu 等）及根目录虚拟环境 `venv-image/`、`venv-doc/` 目前**并不存在于 `~/claudewzp/` 下**（实际只有 wzpclaude）。引用这些路径前先 `ls` 确认存在，不要把总览表当作当前真实目录结构。
3. **ubuntu-system-check 技能的源文件在本仓库**：`.claude/skills/ubuntu-system-check/SKILL.md` 是源文件（git 历史显示曾"安装到全局"，但当前 `~/.claude/skills/` 不存在）。修改技能后，若用户维护全局副本需提醒同步。技能核心流程：sudo 预授权（`echo '<密码>' | sudo -S -v` 缓存凭据）→ 只读检查 → 报告（✅/⚠️/❌）→ 维护动作逐项经用户确认（默认移入回收站而非 rm）。
4. **文档间有内容重叠**：`claudewzp.md` 与 `claude-code-guide.md` 都涉及 CLAUDE.md / skills / memory 配置体系。修改其中一处的约定时，检查另一处是否需同步（如新增技能后更新 `claudewzp.md` 末尾的"配套文件"说明）。
5. **优先级链条**：本文件（wzpclaude 的 CLAUDE.md）< 角色模板（`claudewzp.md`）< 各兄弟项目自己的 CLAUDE.md（仅对各自项目生效）。跨项目任务时，先读目标项目的 CLAUDE.md。

## 常用命令

```bash
git add -A && git commit -m "docs: 更新XXX文档"   # 中文提交信息
```

无构建、测试、lint 命令。验证文档修改的唯一方式是通读上下文确认一致性。
