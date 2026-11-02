# claude-share — 跨机器共享的 Claude 配置包

本目录存放可以经 GitHub 同步到其他机器的 Claude 关键配置：全局设置模板与精选记忆。
其他机器 `git pull` 后按下方步骤即可让 Claude 复用本机的工作方式与关键背景。

## 目录内容

| 文件/目录 | 内容 |
|---|---|
| `settings.example.json` | 全局设置（`~/.claude/settings.json`）脱敏模板：API 代理、权限白名单、插件、主题。**密钥已用占位符替换** |
| `memory/` | 精选关键记忆，原样保留记忆 frontmatter（可直接拷入 Claude 记忆目录） |
| `README.md` | 本文件 |

## 记忆清单

### 通用类（任何机器都适用）

| 文件 | 内容 |
|---|---|
| `work-principles.md` | 工作方式四条原则（先思考后编码 / 简单优先 / 外科手术式修改 / 目标驱动执行） |
| `claude-permissions-authorization.md` | 权限授权约定：git 全部命令与只读查询命令免询问；新增授权保持纯只读标准 |
| `sudo-consent-workflow.md` | sudo 授权约定：ubuntu-system-check 一次输密码直接授权；其他 sudo 逐条询问（已取代旧版 sudo-password-consent） |
| `claudeskill-repo.md` | `~/.claude/skills` 是独立 git 仓库 `wzp1216/claudeskill`，更新 skill 原地 commit+push |
| `libreoffice-parser-diagnosis.md` | LibreOffice 未损坏；`.wps` 文字文档转表格报 no export filter 属预期行为，正确转换路径 |

### 学校背景

| 文件 | 内容 |
|---|---|
| `双高项目概况.md` | 浙江工业职业技术学院第二期省双高专业群建设核心数据（撰写双高材料直接引用） |

### LVpc 本机专属（仅在 LVpc 本机上工作时有意义，其他机器仅作背景了解）

| 文件 | 内容 |
|---|---|
| `lvpc-system-profile.md` | LVpc 机器画像：Windows 双系统（时钟回跳 8h）、Docker 已卸载、打印机单元良性报错 |
| `lvpc-network-security.md` | ufw/fail2ban 加固状态、3 项防护失效待修、钉钉 syslog 刷屏已修复 |
| `lvpc-disk-cleanup.md` | 根分区空间大户位置、清理风险与回收站教训 |
| `system-freeze-diagnosis.md` | 2026-09-07 死机根因（内存耗尽假死）与 earlyoom 防护 |
| `mstsc-gdm-login-loop.md` | mstsc 断开后 GDM 登录循环根因与 KillDisconnected=true 预防 |
| `stm32-gdb-orphan-process.md` | STM32 调试残留孤儿 gdb 进程处理（已部署 gdb-watchdog 定时器） |

## 另一台机器上的同步步骤

1. **克隆仓库**：
   ```bash
   git clone git@github.com:wzp1216/wzpclaude.git
   git clone git@github.com:wzp1216/claudeskill.git ~/.claude/skills
   ```
2. **全局配置**：把 `claudewzp.md` 复制为 `~/.claude/CLAUDE.md`（详见该文件"〇、使用说明"）。
3. **全局设置**：复制 `settings.example.json` 为 `~/.claude/settings.json`，填入两个占位符密钥；同时检查 permissions 中两条 `Bash(source /home/wzp/...)` venv 激活路径是否与新机器一致，不一致则改路径。
4. **记忆**：把 `memory/` 中需要的文件拷入 Claude 对应项目的记忆目录 `~/.claude/projects/<项目目录名转义>/memory/`（Claude 按项目自动加载记忆）。通用类可拷入常用项目的记忆目录；LVpc 专属类只需拷入本机项目记忆目录。
5. **技能**：第 1 步克隆的 `~/.claude/skills` 即技能仓库，Claude Code 直接识别，无需额外安装。

## 回传更新（记忆变化后）

记忆的实时副本在 `~/.claude/projects/*/memory/`，本目录是 2026-11-03 导出的**手动快照**。本机记忆有值得共享的更新时，手动同步到本目录（新增/修改文件后 `git diff` 检查）再 commit+push；不要反向把仓库里的旧快照拷回本机记忆目录覆盖新记忆。

## 安全约定

- **密钥一律不进仓库**：`settings.example.json` 只含占位符；sudo 密码不写入任何文件。
- 记忆内容若涉及敏感数据（学生信息、内部数据），入库前先评估脱敏。
