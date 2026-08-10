# Claude Code CLI 使用教程：从日常编码到高级工作流

> **快速参考卡片** — 聚焦 Claude Code CLI 内部文件的管理与复用，按需跳读，细节随时问 AI。

---

## 目录

1. [基础概念与斜杠命令](#1-基础概念与斜杠命令)
2. [文件体系总览：一张地图看懂所有配置文件](#2-文件体系总览一张地图看懂所有配置文件)
3. [CLAUDE.md — 提示词文件的核心](#3-claudemd--提示词文件的核心)
4. [settings.json — 权限、Hooks、环境变量](#4-settingsjson--权限hooks环境变量)
5. [Skills 技能文件](#5-skills-技能文件)
6. [Memory 记忆文件](#6-memory-记忆文件)
7. [Workflows 工作流文件](#7-workflows-工作流文件)
8. [Keybindings 快捷键配置](#8-keybindings-快捷键配置)
9. [MCP 工具配置](#9-mcp-工具配置)
10. [定时任务文件](#10-定时任务文件)
11. [进阶路径：从日常到高级](#11-进阶路径从日常到高级)
12. [典型场景](#12-典型场景)

---

## 1. 基础概念与斜杠命令

### 1.1 交互方式

| 操作 | 方式 | 说明 |
|------|------|------|
| 自然语言交互 | 直接描述需求 | Claude 自主选择工具执行，无需记命令 |
| 斜杠命令 | `/命令名` | 快速触发内置功能 |
| 终端命令 | `! 命令` | 在对话中直接执行 shell 命令 |
| 文件引用 | 拖拽 / 粘贴路径 / `@文件名` | 让 Claude 关注特定文件 |
| 管道输入 | `echo "..." \| claude` | 从命令行直接传入内容 |

### 1.2 斜杠命令完整参考

以下命令在 Claude Code 交互式会话中直接输入（以 `/` 开头）：

#### 基础操作

| 命令 | 功能 |
|------|------|
| `/help` | 显示帮助信息，列出所有可用命令和技能 |
| `/clear` | 清除当前对话上下文，开始全新会话（相当于"忘记之前聊了什么"） |
| `/exit` | 退出 Claude Code 交互式会话 |
| `/model` | 查看和切换当前使用的 AI 模型 |
| `/config` | 打开配置面板，管理模型、权限、主题等设置 |
| `/context` | 显示当前会话的上下文使用情况（已用 token / 上限） |
| `/status` | 查看当前会话状态，包括模型、工作目录、活跃的子代理等 |

#### 工作模式

| 命令 | 功能 |
|------|------|
| `/plan` | 进入计划模式：Claude 先探索代码、设计方案，你确认后再动手写代码 |
| `/fast` | 切换快速模式：使用 Claude Opus 更快输出（不降级到小模型），再次输入 `/fast` 关闭 |

**`/plan` 详细用法**：

```
# 手动进入计划模式
/plan
# 然后描述你的需求，Claude 会：
# 1. 探索相关代码文件
# 2. 设计实现方案
# 3. 列出涉及的文件和改动步骤
# 4. 等待你确认后再执行

# 也可以在进入计划模式时直接带需求
# 输入 /plan 后立即描述："我要给用户模块加上权限控制"
```

**适用场景**：新增功能、重构、架构选型、影响多个文件的改动。
**不适用**：修一行 bug、改个变量名、加条日志。

#### 代码操作

| 命令 | 功能 |
|------|------|
| `/init` | 分析当前项目并自动生成 `CLAUDE.md`，Claude 扫描目录结构、依赖、代码风格后输出规范文件 |
| `/review` | 代码审查：审查当前分支的改动或指定的 PR |
| `/security-review` | 安全审计：检查代码中的安全漏洞（注入、XSS、敏感信息泄露等） |
| `/simplify` | 代码简化：检查改动代码的可复用性、冗余、简化机会，自动修复 |
| `/run` | 启动并验证应用：查找项目的启动方式，运行并确认改动生效 |
| `/pr-comments` | 查看当前 PR 的评审意见并逐条处理 |

**`/review` 详细用法**：

```
/review                              → 审查当前未提交的改动
/review                               → 后面贴 GitHub PR 链接审查指定 PR
"帮我 review 这个 PR"                 → 等同效果，自然语言也行
```

**`/init` 详细用法**：

```
/init                                → 自动扫描项目，生成 CLAUDE.md
# Claude 会分析：
#   - package.json / requirements.txt 等依赖文件 → 技术栈
#   - 目录结构 → 项目组织方式
#   - tsconfig / eslintrc 等 → 编码规范
#   - README.md → 项目说明
# 生成后你可以审阅修改，确认后保存到项目根目录
```

#### 任务与自动化

| 命令 | 功能 |
|------|------|
| `/loop` | 周期性重复执行命令，适合轮询、定时检查 |
| `/tasks` | 查看后台运行的任务列表（子代理、后台 shell 等） |
| `/workflows` | 查看正在运行的工作流进度（多代理编排任务） |

**`/loop` 详细用法**：

```
# 基本语法：/loop <间隔> <命令或提示词>
/loop 5m 检查 CI 构建状态           → 每 5 分钟检查一次
/loop 30m 运行 npm run test 并报告  → 每 30 分钟跑一次测试
/loop 10m /review                   → 每 10 分钟审查一次代码

# 间隔格式：
#   s = 秒（如 30s）
#   m = 分钟（如 5m）
#   h = 小时（如 2h）

# 停止循环：再次输入 /loop（不带参数）或直接说"停止循环"
```

#### 工具与配置

| 命令 | 功能 |
|------|------|
| `/update-config` | 通过对话更新 `settings.json` 配置（权限、hooks、环境变量等） |
| `/keybindings` | 查看和自定义键盘快捷键，写入 `~/.claude/keybindings.json` |
| `/design-sync` | 将本地组件库同步到 claude.ai 设计系统项目 |
| `/permissions` | 查看和调整当前工具权限设置 |

#### 输出与分享

| 命令 | 功能 |
|------|------|
| `/export` | 导出当前会话记录 |
| `/share` | 生成会话分享链接 |
| `/feedback` | 提交产品反馈 |

### 1.3 自然语言也能做的事

以下操作既能用命令，也能用自然语言——两者等效：

```
"帮我记住..."              → 写入 Memory
"允许 npm 命令"            → 更新 settings.json 权限
"每天早上 9 点提醒我..."    → 创建持久定时任务
"创建工作树"               → 进入隔离的工作分支
"把 Ctrl+S 改成提交"       → 修改快捷键
```

---

## 2. 文件体系总览：一张地图看懂所有配置文件

搞清楚「什么文件放哪、谁优先」是管理 Claude Code 的第一步。

### 2.1 目录结构全景

```
全局（所有项目共用）                    项目级（单个项目）
─────────────────────────          ─────────────────────────
~/.claude/                         ./（项目根目录）
│                                  │
├── CLAUDE.md          ← 全局偏好    ├── CLAUDE.md          ← 项目规范
│                                  │
├── settings.json      ← 全局设置    ├── .claude/
│                                  │   ├── settings.json      ← 项目设置
├── keybindings.json   ← 快捷键      │   ├── settings.local.json← 本地覆盖（不提交 git）
│                                  │   │
├── mcp.json           ← MCP 工具    │   ├── skills/            ← 项目技能
│                                  │   │   ├── deploy.md
├── skills/            ← 全局技能    │   │   └── new-page.md
│   ├── pr-template.md              │   │
│   └── commit.md                   │   ├── workflows/         ← 项目工作流
│                                  │   │   ├── audit.md
├── workflows/         ← 全局工作流  │   │   └── migrate.md
│   └── research.md                  │   │
│                                  │   └── scheduled_tasks.json← 持久定时任务
├── plugins/           ← 插件目录    │
│                                  │
└── projects/                       │
    └── <project-hash>/             │
        ├── memory/    ← 项目记忆    │
        │   ├── arch.md             │
        │   ├── why-redis.md        │
        │   └── MEMORY.md ← 索引    │
        └── <session-id>.jsonl ← 会话记录 │
```

### 2.2 优先级规则

```
项目级 > 全局级

发生冲突时项目级覆盖全局。例如：
  ~/.claude/CLAUDE.md  写 "包管理器用 npm"
  ./CLAUDE.md          写 "包管理器用 pnpm"
  → 当前项目使用 pnpm

同级冲突时：
  .claude/settings.local.json > .claude/settings.json
  （local.json 是个人本地覆盖，优先级最高）
```

### 2.3 哪些该提交到 Git，哪些不该

| 文件 | 提交到 Git？ | 理由 |
|------|-------------|------|
| `./CLAUDE.md` | ✅ 提交 | 团队共享项目规范 |
| `./.claude/settings.json` | ✅ 提交 | 共享权限和 hooks |
| `./.claude/settings.local.json` | ❌ gitignore | 个人本地覆盖，不应提交 |
| `./.claude/skills/*.md` | ✅ 提交 | 团队共享工作流 |
| `./.claude/workflows/*.md` | ✅ 提交 | 团队共享工作流编排 |
| `./.claude/scheduled_tasks.json` | ❌ gitignore | 个人定时任务 |
| `~/.claude/CLAUDE.md` | — | 不在项目内，纯个人偏好 |
| `~/.claude/settings.json` | — | 不在项目内，全局设置 |
| `~/.claude/keybindings.json` | — | 纯个人偏好 |
| `~/.claude/mcp.json` | — | 可能含敏感凭据，全局配置 |

---

## 3. CLAUDE.md — 提示词文件的核心

**位置**：
- 项目级：`./CLAUDE.md`（项目根目录）
- 全局级：`~/.claude/CLAUDE.md`

**加载机制**：Claude 启动会话时自动读取。先加载全局的，再加载项目的。项目级内容会补充（而非完全覆盖）全局内容。

**核心价值**：一次编写，之后每次对话 Claude 都自动带上这些上下文，你不再需要反复解释技术栈、规范、命令。

### 3.1 项目级 CLAUDE.md 详细示例

```markdown
# CLAUDE.md

## 技术栈
- Vue 3 + TypeScript + Vite 5
- Pinia 状态管理，Element Plus 2.x 组件库
- Axios 请求封装，Mock.js 模拟数据
- Vitest 单元测试，Playwright E2E 测试

## 项目结构
```
src/
├── api/           # API 请求模块，按业务模块分文件（user.ts, order.ts）
├── assets/        # 静态资源：图片、字体、全局样式
├── components/    # 公共组件，每个组件一个文件夹
├── composables/   # 组合式函数（useXxx.ts）
├── router/        # 路由配置，模块名 kebab-case
├── store/         # Pinia 状态管理
├── utils/         # 工具函数
└── views/         # 页面组件
```

## 编码规范
- 组件必须用 `<script setup lang="ts">`，禁止 Options API 和 class 组件
- 组件名 PascalCase，文件名 kebab-case
- 样式统一用 SCSS，全局变量定义在 `src/assets/styles/variables.scss`
- API 请求统一通过 `src/api/request.ts` 中的 axios 实例
- 类型定义放在 `src/types/`，接口以 `I` 为前缀（如 `IUser`）
- 组合式函数以 `use` 为前缀（如 `useAuth`）

## 常用命令
| 场景 | 命令 |
|------|------|
| 开发 | `npm run dev` |
| 构建 | `npm run build` |
| 单元测试 | `npm run test` |
| E2E 测试 | `npm run test:e2e` |
| 代码检查 | `npm run lint` |
| 类型检查 | `npm run type-check` |

## 注意事项
- 图片放 `src/assets/images/`，引用路径用 `@/assets/images/xxx`
- 路由懒加载：`() => import('@/views/模块名/页面名.vue')`
- 敏感信息用环境变量，不要硬编码
- API 接口变更后，同步更新 `src/types/api/` 下的类型定义
```

### 3.2 全局 CLAUDE.md — 个人偏好

这个文件影响**所有项目**的 Claude 行为：

```markdown
# 全局偏好

## 编码习惯
- 变量命名优先清晰而非简洁，避免单字母（除循环变量 i, j）
- 函数保持单一职责，超过 30 行建议拆分
- 错误处理：至少 log 出来，不要让异常静默吞掉
- 不过度设计：先用简单方案，确认需要扩展再重构
- TypeScript 开启 strict 模式，避免 any

## 交互偏好
- 先给方案大纲，确认后再写代码
- 修改代码时解释改了什么、为什么
- 用中文交流，代码注释用英文
- 涉及多文件改动时，每改完一个模块停下来确认

## 环境
- 默认用 bash shell
- 包管理器优先 pnpm > npm > yarn
- Git 提交信息用 Conventional Commits 规范

## 工具偏好
- 测试框架优先 vitest（前端）或 pytest（Python）
- 格式化用 prettier，Lint 用 eslint
```

### 3.3 模板化复用 — 告别重复写提示词

**建立模板库** `~/templates/`：

```
~/templates/
├── vue3-admin.md         # Vue3 + TS 后台管理
├── vue3-h5.md            # Vue3 移动端 H5
├── react-next.md         # React + Next.js
├── python-fastapi.md     # Python FastAPI 后端
├── python-django.md      # Python Django 后端
├── node-express.md       # Node.js Express
├── go-gin.md             # Go Gin 框架
└── rust-actix.md         # Rust Actix Web
```

**使用流程**：

```bash
# 1. 新建项目时复制最接近的模板
cp ~/templates/vue3-admin.md ./CLAUDE.md

# 2. 让 Claude 微调
"根据这个项目的实际情况微调 CLAUDE.md：
 - 组件库换成 Ant Design Vue
 - 包管理器用 yarn
 - 加上 Docker 部署命令"

# 3. 开始开发，Claude 已完全了解规范
```

### 3.4 CLAUDE.md 编写原则

```
✅ 具体可执行
   "API 请求放在 src/api/，文件名为 模块名.ts，统一从 src/api/request.ts 导入 axios 实例"
❌ 模糊空话
   "代码要写得好"

✅ 给出限制和边界
   "禁止 class 组件和 Options API，必须用 Composition API + <script setup>"
❌ 没有约束
   "用 Vue 写"

✅ 包含可执行的命令
   用表格列出：开发 npm run dev | 测试 npm run test | 构建 npm run build
❌ 不提供命令
   "需要好好测试"

✅ 新项目一开始就加
   哪怕就 5 行：技术栈 + 入口文件 + 启动命令，也已经省了后面的解释成本
❌ 等项目长大再补
   早期代码就已经开始偏离预期规范
```

### 3.5 CLAUDE.md 的作用边界

```
CLAUDE.md 适合写：
  ✅ 技术栈和版本号        ✅ 目录结构约定
  ✅ 编码规范              ✅ 常用命令
  ✅ 禁止事项（不要用 X）   ✅ 命名约定

CLAUDE.md 不适合写：
  ❌ 业务逻辑（那是代码本身的职责）
  ❌ 临时的、一次性的说明（在对话中说就行）
  ❌ 太长太细的规则（太长 Claude 读取效率降低，建议控制在 200 行以内）
  ❌ 敏感信息（API key 等，用环境变量）
```

---

## 4. settings.json — 权限、Hooks、环境变量

**位置**：
- 全局：`~/.claude/settings.json`
- 项目：`.claude/settings.json`（团队共享，提交 git）
- 本地覆盖：`.claude/settings.local.json`（个人，不提交，优先级最高）

### 4.1 权限管理详解

控制哪些工具 Claude 可以**自动执行**，哪些需要**弹出确认**，哪些**禁止执行**。

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(git status)",
      "Bash(git diff)",
      "Bash(git log *)",
      "Bash(ls *)",
      "Read(*)",
      "Edit(*)",
      "Write(*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(curl *)",
      "Bash(wget *)"
    ],
    "defaultMode": "acceptEdits"
  }
}
```

#### 权限匹配语法

```
精确匹配：  "Bash(npm run test)"       → 只匹配这个精确命令
通配符：    "Bash(npm run *)"          → 匹配 npm run dev/build/test 等
全局通配：  "Read(*)"                  → 允许读取所有文件
目录限定：  "Write(/src/**)"           → 只允许写入 src 目录下
```

#### 权限管理方式

```
# 方式一：通过对话（推荐）
"允许 npm 相关的所有命令"
"禁止删除命令"
"把 git push 权限加到项目 settings.json"

# 方式二：使用技能
/update-config                        → 通过对话引导更新配置

# 方式三：手动编辑
编辑 ~/.claude/settings.json 或 .claude/settings.json
```

### 4.2 Hooks — 事件触发自动操作

在 Claude Code 的**生命周期事件**前后自动执行脚本。

#### 可用的事件钩子

| 事件 | 触发时机 | 典型用途 |
|------|----------|----------|
| `PreToolUse` | 工具执行前 | 检查/阻止危险操作 |
| `PostToolUse` | 工具执行后 | 自动格式化、记录日志 |
| `Notification` | 特定通知事件 | 桌面通知、IM 推送 |
| `SessionStart` | 会话开始时 | 加载环境、显示提示 |
| `SessionEnd` | 会话结束前 | 清理、保存状态 |
| `PreMessage` | 发送消息前 | 注入额外上下文 |
| `PostMessage` | 收到回复后 | 处理回复内容 |

#### 示例一：代码保存后自动格式化

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{
          "type": "command",
          "command": "npx prettier --write \"${CLAUDE_TOOL_INPUT_FILE_PATH}\" 2>/dev/null || true"
        }]
      }
    ]
  }
}
```

**解释**：每次 Claude 用 Write 或 Edit 工具修改文件后，自动对该文件运行 prettier 格式化。`matcher` 用 `|` 分隔多个匹配项。

#### 示例二：阻止危险 Git 操作

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git push --force*)",
        "hooks": [{
          "type": "command",
          "command": "echo '⚠️ Force push 被 Hook 拦截！如需执行请手动操作' && exit 1"
        }]
      }
    ]
  }
}
```

**解释**：在 git push --force 执行前拦截，`exit 1` 会阻止执行。

#### 示例三：任务完成桌面通知

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "TaskComplete",
        "hooks": [{
          "type": "command",
          "command": "notify-send 'Claude Code' '任务已完成'"
        }]
      }
    ]
  }
}
```

#### 可用的环境变量（在 hook 命令中使用）

| 变量 | 含义 |
|------|------|
| `$CLAUDE_TOOL_INPUT_FILE_PATH` | 被修改的文件路径（PostToolUse + Write/Edit） |
| `$CLAUDE_PROJECT_DIR` | 当前项目根目录 |
| `$CLAUDE_SESSION_ID` | 当前会话 ID |

### 4.3 环境变量

为 Claude 的运行环境设置环境变量：

```json
{
  "env": {
    "NODE_ENV": "development",
    "DEBUG": "myapp:*",
    "DATABASE_URL": "postgresql://localhost:5432/dev_db"
  }
}
```

**注意**：`settings.local.json` 优先级最高，适合放个人开发环境的环境变量，不提交到 Git。

---

## 5. Skills 技能文件

**位置**：
- 项目级：`.claude/skills/*.md`
- 全局级：`~/.claude/skills/*.md`

**作用**：把重复性工作流封装成 `/技能名`，一次编写，跨会话、跨项目复用。

**优先级**：如果项目级和全局级有同名技能，项目级的优先。

### 5.1 内置技能完整参考

| 技能名 | 调用方式 | 功能描述 |
|--------|----------|----------|
| `review` | `/review` | 审查当前改动或指定 PR |
| `security-review` | `/security-review` | 安全漏洞审计 |
| `simplify` | `/simplify` | 检查代码复用性、简化冗余 |
| `init` | `/init` | 分析项目并生成 CLAUDE.md |
| `run` | `/run` | 启动项目并验证改动 |
| `loop` | `/loop 5m 指令` | 周期性重复执行 |
| `dataviz` | `/dataviz` | 数据可视化（图表、仪表盘） |
| `update-config` | `/update-config` | 通过对话更新 settings.json |
| `keybindings-help` | `/keybindings` | 自定义键盘快捷键 |
| `pr-comments` | `/pr-comments` | 逐条处理 PR 评审意见 |

### 5.2 技能文件格式

一个技能就是一个 Markdown 文件，用 YAML frontmatter 声明元数据：

```markdown
---
description: 一句话描述这个技能做什么
---

技能的具体指令内容（Markdown 格式）
```

### 5.3 创建自定义技能 — 示例

**项目级部署技能** `.claude/skills/deploy.md`：

```markdown
---
description: 构建并部署到 staging 环境，包含预检查、构建、部署、验证四步
---

## 部署流程

### 第一步：部署前检查
1. 确认当前在 `main` 分支：`git branch --show-current`
2. 确认工作区干净：`git status --porcelain`（如有未提交改动，先提交或 stash）
3. 运行检查和测试：
   - `npm run lint`
   - `npm run type-check`
   - `npm run test`
4. 如任一步失败，**停止部署** 并报告失败原因

### 第二步：构建
1. 获取当前版本号：`node -p "require('./package.json').version"`
2. `npm run build`
3. 确认构建产物存在：`ls -la dist/`

### 第三步：部署
1. 同步文件到 staging 服务器：
   `rsync -avz --delete dist/ user@staging.example.com:/var/www/app/`
2. 重启服务（如需要）：
   `ssh user@staging.example.com 'systemctl restart nginx'`

### 第四步：验证
1. 健康检查：`curl -s -o /dev/null -w "%{http_code}" https://staging.example.com/health`
2. 如果返回 200，报告 **"部署成功！版本 X.Y.Z 已上线 staging"**
3. 如果非 200，报告 **"部署可能有问题，健康检查返回 XXX"**
```

使用：在对话中输入 `/deploy`

**全局级 PR 模板技能** `~/.claude/skills/pr-template.md`：

```markdown
---
description: 按团队规范生成 PR 描述：包含变更摘要、测试步骤、截图
---

## PR 描述模板

请按以下结构生成 PR 描述：

### 变更摘要
用 2-3 句话说明这个 PR 做了什么、为什么这样做。

### 详细改动
- 列出每个主要改动点，用无序列表
- 标注涉及的文件

### 测试步骤
1. 列出 reviewer 如何验证这个改动
2. 包含具体的命令或操作步骤

### 截图/录屏
- 如果是 UI 改动，提醒我附上截图

### Checklist
- [ ] 代码已通过 lint 检查
- [ ] 单元测试已添加/更新
- [ ] 已在本地验证功能正常

生成后提醒我补充截图。
```

使用：`/pr-template`

### 5.4 技能文件管理策略

```
全局技能 → 放所有项目通用的流程：
  ~/.claude/skills/
  ├── pr-template.md        ← 任何项目都要写 PR
  ├── commit.md             ← 统一的 commit 信息规范
  ├── new-feature.md        ← 标准分支创建流程
  └── code-trace.md         ← 追踪某个功能的所有相关代码

项目技能 → 放这个项目特有的流程：
  .claude/skills/
  ├── deploy.md             ← 这个项目特定的部署方式
  ├── api-gen.md            ← 从 Swagger/OpenAPI 生成接口代码
  ├── new-page.md           ← 按项目模板生成标准 CRUD 页面
  └── db-migrate.md         ← 数据库迁移操作
```

**判断放哪的原则**：这个流程换了一个项目还能用吗？能 → 全局；不能 → 项目级。

---

## 6. Memory 记忆文件

**位置**：`~/.claude/projects/<project-hash>/memory/`

**作用**：跨会话记住**关键决策、偏好纠正、踩坑经验**。每次新会话自动加载相关记忆。

**和 CLAUDE.md 的关键区别**：

```
CLAUDE.md  → "怎么做"（规范、流程、命令）
Memory     → "为什么这样做" / "上次踩了什么坑"（决策背景、经验教训）
```

### 6.1 记忆文件格式

每个记忆是一个独立的 Markdown 文件，用 YAML frontmatter 标注元数据：

```markdown
---
name: payment-idempotency-design
description: 支付模块为什么用 Redis + 令牌方案做幂等，而不是分布式锁
metadata:
  type: project
---

## 背景
支付模块在 2024-Q3 出现了重复扣款问题，需要引入幂等机制。

## 方案对比
- 分布式锁：简单但有单点风险，锁超时可能导致误放行
- Redis + 令牌：每个支付请求生成唯一令牌，Redis 原子性校验
- 数据库唯一约束：最可靠但性能较差

## 最终选择
用了 Redis + 令牌方案（详见 [[payment-token-implementation]]）。
因为：
1. Redis 在我们的架构中已经是核心组件，不引入新依赖
2. 令牌存在 body 里，比依赖 HTTP 方法语义更可靠
3. 性能满足要求（P99 < 5ms）

**为什么没用分布式锁**：见 [[why-not-distributed-lock]]

## 注意事项
- 令牌过期时间设置为 30 分钟，超时后可重试
- 支付回调接口也做了幂等（见 [[callback-idempotency]]）
```

### 6.2 四种记忆类型

| 类型 | 用途 | 示例内容 |
|------|------|----------|
| `user` | 你是谁、角色、长期偏好 | "全栈开发者，10 年经验，偏好 TypeScript 严格模式" |
| `feedback` | 你给过的纠正和反馈 | "之前指出过不要用 any 类型，要定义具体 interface" |
| `project` | 项目级决策和背景 | "为什么选 Redis 而非 Kafka 做消息队列" |
| `reference` | 外部资源链接 | "后端 API 文档：https://internal-api.example.com/docs" |

### 6.3 操作记忆

```
# 让 Claude 帮你记住
"帮我记住：XX 项目支付模块必须做幂等，用的是 Redis + 令牌方案"
"记住我偏好 vitest 而不是 jest"
"记住这个项目用的 Node 版本是 20 LTS"

# Claude 会自动记住的内容：
- 你说"下次不要这样写" → 记录为 feedback 类记忆
- 反复提到的项目背景信息 → 记录为 project 类记忆
- 你纠正 Claude 的方式 → 记录为 feedback 类记忆

# 记忆之间的互相引用
在记忆文件中可以用 [[另一个记忆的 name]] 形成知识网络：
"见 [[payment-token-implementation]]"
"对比方案见 [[why-not-distributed-lock]]"
```

### 6.4 记忆索引文件 MEMORY.md

每个项目的 memory 目录下有一个 `MEMORY.md` 索引文件，列出所有记忆：

```markdown
- [payment-idempotency-design](payment-idempotency-design.md) — 支付幂等方案选型
- [why-not-distributed-lock](why-not-distributed-lock.md) — 为什么没用分布式锁
- [user-preferences](user-preferences.md) — 开发者偏好
```

**不需要手动维护这个文件**，Claude 在创建/更新记忆时自动更新索引。

### 6.5 记忆管理建议

```
适合记录为 Memory：
  ✅ 重要决策及其原因（"为什么选了 A 而不是 B"）
  ✅ 踩过的坑和教训（"上次这里出过问题，因为..."）
  ✅ 长期有效的偏好（"我总是用 vitest"）
  ✅ 外部资源链接（API 文档、设计稿地址）

不适合记录为 Memory：
  ❌ 临时的、一次性的信息
  ❌ 已经在 CLAUDE.md 里写了的规范
  ❌ 代码细节（代码本身是真相来源）
  ❌ 频繁变动的内容
```

---

## 7. Workflows 工作流文件

**位置**：
- 项目级：`.claude/workflows/*.md`
- 全局级：`~/.claude/workflows/*.md`

**作用**：编排**多个子代理协作**完成大规模任务。Skill 是「一个流程」，Workflow 是「一群代理各司其职、互相配合」。

### 7.1 什么时候需要 Workflow（而非 Skill）

```
用 Skill 的情况：           用 Workflow 的情况：
 单个流程                    多个代理并行协作
 步骤固定                    需要并行探索 + 对比 + 综合
 不需要多角度交叉验证         需要多个代理独立审查再投票
 适合串行执行                适合并行执行

示例：
 Skill:  /deploy            → 固定的部署步骤，一个人就能完成
 Workflow: /audit           → 同时在 5 个模块找 bug，然后交叉验证
```

### 7.2 适用场景

| 场景 | 为什么用 Workflow |
|------|-------------------|
| 全面代码审计 | 多模块并行审查 → 对抗验证 → 综合报告 |
| 大规模迁移 | 发现所有涉及点 → 逐文件改造 → 验证通过 |
| 技术选型调研 | 多方向并行搜索 → 交叉确认信息 → 综合对比 |
| 跨模块重构 | 各模块独立分析 → 汇总冲突 → 分模块实施 |
| 多维度测试 | 单元测试/集成测试/E2E 并行 → 汇总结果 |

### 7.3 保存为文件 vs 临时描述

```bash
# ❌ 每次临时描述 — 冗长且不一致
"帮我做一个全面的代码审计：
 先在 models/ views/ controllers/ services/ utils/ 五个目录
 分别找 bug、安全漏洞、性能问题、代码坏味道，
 然后对每个发现的严重程度打分，
 然后对高危发现做对抗验证（用 3 个代理独立审查），
 然后按严重度排序出综合报告..."

# ✅ 保存为 Workflow 文件 — 一行调用
/audit
```

### 7.4 工作流文件结构

```markdown
---
description: 全面代码审计：多维度扫描 → 对抗验证 → 综合报告
---

## 审计范围
扫描以下目录：`src/models/` `src/views/` `src/controllers/` `src/services/` `src/utils/`

## 扫描维度
1. **Bug 检测**：空指针、未处理异常、竞态条件、边界条件
2. **安全漏洞**：注入、XSS、敏感信息泄露、权限绕过
3. **性能问题**：N+1 查询、内存泄漏、不必要的循环、大对象拷贝
4. **代码坏味道**：重复代码、过长函数、过深嵌套、硬编码

## 验证规则
对每个高危发现，启动 3 个独立代理做对抗验证：
- 代理 A：尝试确认这个漏洞真实存在
- 代理 B：尝试证明这是误报
- 代理 C：评估修复成本和风险

如果 2/3 确认，则纳入最终报告。

## 输出要求
按严重度（Critical > High > Medium > Low）分组，每组包含：
- 文件路径和行号
- 问题描述
- 复现步骤
- 修复建议
```

### 7.5 工作流文件管理

```
项目级 (.claude/workflows/)：
  ├── audit.md         ← 全面代码审计
  ├── migrate.md       ← 依赖升级/API 迁移
  ├── release.md       ← 发布前检查清单
  └── refactor.md      ← 跨模块重构

全局级 (~/.claude/workflows/)：
  └── tech-research.md ← 技术选型调研
```

---

## 8. Keybindings 快捷键配置

**位置**：`~/.claude/keybindings.json`

### 8.1 默认快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Enter` | 提交消息 |
| `Ctrl+C` | 中断当前操作 |
| `Ctrl+D` | 退出会话 |
| `Ctrl+L` | 清屏 |
| `↑/↓` | 浏览历史消息 |
| `Tab` | 自动补全文件路径 |

### 8.2 自定义快捷键

```json
{
  "bindings": [
    {
      "key": "ctrl+s",
      "command": "submit",
      "description": "Ctrl+S 提交消息"
    },
    {
      "key": "ctrl+k",
      "command": "clear",
      "description": "Ctrl+K 清屏"
    },
    {
      "key": "ctrl+shift+r",
      "command": "review",
      "description": "快速触发代码审查"
    }
  ]
}
```

### 8.3 管理方式

```
/keybindings                      → 查看当前快捷键
"把提交改成 Ctrl+Enter"            → 通过对话修改
"给代码审查加个快捷键 Ctrl+Shift+R" → 添加新快捷键
```

---

## 9. MCP 工具配置

**位置**：`~/.claude/mcp.json`

**作用**：通过 Model Context Protocol 连接外部工具和数据源，让 Claude 能访问数据库、云服务、内部 API 等。

### 9.1 MCP 服务器类型

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.github.com",
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      }
    },
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost:5432/mydb"
      }
    },
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "/path/to/allowed/dir"]
    }
  }
}
```

**两种类型**：
- `http`：通过 HTTP 连接远程 MCP 服务
- `stdio`：启动本地进程，通过标准输入/输出通信

### 9.2 常见 MCP 服务器

| 服务器 | 用途 |
|--------|------|
| `@anthropic/mcp-server-postgres` | PostgreSQL 数据库查询 |
| `@anthropic/mcp-server-filesystem` | 安全的文件系统访问 |
| `@anthropic/mcp-server-github` | GitHub API 集成 |
| `@anthropic/mcp-server-slack` | Slack 消息集成 |
| 自定义 MCP 服务器 | 连接公司内部系统 |

---

## 10. 定时任务文件

### 10.1 会话内临时定时（重启消失）

使用 `/loop` 命令，任务只在当前会话有效：

```
/loop 30s 检查 npm run dev 是否还在运行    → 每 30 秒检查
/loop 5m 查看 git status                   → 每 5 分钟
/loop 1h 运行 npm run test                 → 每小时
```

### 10.2 持久化定时任务（写入文件）

**位置**：`.claude/scheduled_tasks.json`

通过对话创建，写入磁盘文件，**重启后依然生效**（7 天自动过期）：

```
"每天早上 9 点提醒我 review 待处理的 PR"
"每个工作日 17:00 提醒我提交代码"
"每 2 小时跑一次 npm run test"
```

**Cron 表达式格式**（5 字段：分 时 日 月 星期）：

```
0 9 * * *       → 每天 9:00
57 8 * * 1-5    → 工作日 8:57（避开整点，减少系统负载高峰）
*/30 * * * *    → 每 30 分钟
0 */2 * * *     → 每 2 小时
```

**管理持久任务**：

```
"列出我的定时任务"         → 查看所有持久任务
"取消每天早上 9 点的提醒"   → 删除指定任务
```

---

## 11. 进阶路径：从日常到高级

```
┌─────────────────────────────────────────────────────────┐
│ 阶段 1：零配置上手（第 1 天）                              │
├─────────────────────────────────────────────────────────┤
│ • 直接对话，自然语言描述需求                                │
│ • 习惯用 ! 前缀执行终端命令                                │
│ • 了解 /help /clear /model 三个基础命令                    │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ 阶段 2：提高效率（第 1 周）                                │
├─────────────────────────────────────────────────────────┤
│ • 写 ./CLAUDE.md（5 分钟，以后省 50 次重复解释）            │
│ • 写 ~/.claude/CLAUDE.md（个人偏好一劳永逸）               │
│ • 在 settings.json 中 allow 常用命令，减少确认弹窗          │
│ • 学会用 /plan 处理复杂改动                                │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ 阶段 3：流程自动化（2-4 周）                               │
├─────────────────────────────────────────────────────────┤
│ • 创建 .claude/skills/ 封装重复流程（部署、生成模板等）      │
│ • 用 Memory 记录关键决策和踩坑经验                          │
│ • 建立 CLAUDE.md 模板库（~/templates/）                   │
│ • 配置 Hooks 自动格式化代码                                │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ 阶段 4：团队协作（1-2 个月）                               │
├─────────────────────────────────────────────────────────┤
│ • 把 CLAUDE.md + settings.json + skills/ 提交 Git         │
│ • 团队成员 git pull 即获得相同的 Claude 规范                 │
│ • 统一团队 MCP 服务器配置                                  │
│ • 用 settings.local.json 管理个人本地差异                   │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ 阶段 5：高级编排（按需）                                   │
├─────────────────────────────────────────────────────────┤
│ • Workflows 编排多代理并行任务（审计、迁移、调研）           │
│ • 定时任务自动巡检（CI 状态、每日报告）                      │
│ • 自定义 Keybindings 提升操作速度                          │
│ • MCP 连接内部系统（数据库、监控、日志平台）                  │
└─────────────────────────────────────────────────────────┘
```

---

## 12. 典型场景

### 场景 A：接手一个新项目

```
步骤 1：让 Claude 了解项目
  "帮我分析这个项目的结构和关键技术栈"

步骤 2：生成 CLAUDE.md
  /init
  → Claude 扫描项目，生成 CLAUDE.md
  → 你审阅调整，确认保存

步骤 3：建立项目记忆
  "帮我记住这个项目的核心架构决策：
   - 为什么数据库用 PostgreSQL 而不是 MySQL
   - 为什么消息队列选了 Redis Streams"

步骤 4：开始高效开发
  "在 src/api/ 下新增订单模块的接口文件"
  → Claude 已完全了解规范，直接按约定写
```

### 场景 B：创建同类型新项目

```bash
# 1. 复制最接近的模板
cp ~/templates/vue3-admin.md ./CLAUDE.md

# 2. 让 Claude 微调
"微调 CLAUDE.md：
 - 组件库从 Element Plus 换成 Ant Design Vue
 - 包管理器用 yarn
 - 加上 Docker Compose 开发流程"

# 3. 开始开发
"搭建项目骨架：路由、布局、登录页、权限守卫"
```

### 场景 C：为团队建立 Claude Code 规范体系

```
第一步（个人）：
  写好 ~/.claude/CLAUDE.md（个人偏好）

第二步（项目）：
  写好 ./CLAUDE.md（项目技术栈和规范）
  写好 .claude/settings.json（团队共享的权限和 hooks）
  写好常用 Skills：.claude/skills/deploy.md、new-page.md

第三步（提交）：
  git add CLAUDE.md .claude/
  git commit -m "chore: 添加 Claude Code 项目配置"
  → 团队成员 pull 后立即获得相同规范

第四步（每人）：
  每个人在 ~/.claude/CLAUDE.md 中写个人编码偏好
  每个人如需本地差异，用 .claude/settings.local.json（不提交）

第五步（持续改进）：
  发现新的规范 → 更新 CLAUDE.md，提交
  发现重复流程 → 封装成 Skill，提交
  发现重要的踩坑 → 写成 Memory
```

### 场景 D：项目复盘与经验沉淀

```
"帮我回顾这个项目，总结以下内容：

1. 哪些规范值得加入 CLAUDE.md 模板？
   （下次同类项目可以直接用）

2. 哪些关键决策值得记录为 Memory？
   （为什么选了某个方案、踩了什么坑）

3. 哪些重复操作可以封装成 Skill？
   （部署、生成代码模板、数据库迁移等）

4. CLAUDE.md 中有哪些内容实际上没用？
   （清理冗余，保持文件精简）"
```

### 场景 E：为现有项目快速建立 Claude 规范

```bash
# 一个命令搞定
/init

# 然后对话微调
"在 CLAUDE.md 中补充：
 - 我们用的不是默认的测试框架，是 vitest
 - 禁止使用 axios 以外的 HTTP 库
 - 路由守卫统一放在 src/router/guards.ts"
```

---

## 快速决策表

| 我想... | 改哪个文件 / 怎么做 |
|----------|---------------------|
| 告诉 Claude 项目技术栈和规范 | `./CLAUDE.md` |
| 所有项目都用相同的编码风格 | `~/.claude/CLAUDE.md` |
| 让 Claude 自动执行 npm/git 命令 | `settings.json` → permissions.allow |
| 每次保存文件自动格式化 | `settings.json` → hooks.PostToolUse |
| 阻止 Claude 执行危险命令 | `settings.json` → permissions.deny |
| 封装一个部署流程 | `.claude/skills/deploy.md` |
| 封装一个 PR 描述模板 | `~/.claude/skills/pr-template.md` |
| 记住上次为什么选了 Redis | 对话中说"帮我记住..."→ Memory |
| 编排多代理做全面审计 | `.claude/workflows/audit.md` |
| 自定义键盘快捷键 | `~/.claude/keybindings.json` 或 `/keybindings` |
| 连接公司内部 API | `~/.claude/mcp.json` |
| 每天早上自动检查 CI | "每天早上 9 点..." → `.claude/scheduled_tasks.json` |
| 不想让个人配置提交到 Git | `.claude/settings.local.json` |
| 新成员快速上手项目规范 | 直接 git pull → CLAUDE.md + skills 自动生效 |
| 查看当前上下文用了多少 token | `/context` |
| 切换使用的 AI 模型 | `/model` |
| 周期性检查某个状态 | `/loop 5m 检查 CI 状态` |

---

## 核心原则

> 1. **CLAUDE.md 是第一生产力** — 5 分钟写，后面省 50 次解释
> 2. **模板化复用** — 同类项目复制 CLAUDE.md 模板，不要每次都从零写
> 3. **先项目级再全局** — 能给团队共享的放项目级（提交 Git），纯个人偏好的放全局
> 4. **渐进积累** — 每次复盘都沉淀：更新模板、记录记忆、封装技能
> 5. **随时问 AI** — 不确定怎么配，直接问 Claude："怎么给这个项目加一个部署 Skill？"

---

*最后更新：2026-08-04*
*生成工具：Claude Code*
