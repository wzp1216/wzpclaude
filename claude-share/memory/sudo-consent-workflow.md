---
name: sudo-consent-workflow
description: 用户对 sudo 命令的授权约定：ubuntu-system-check 运行前一次提示密码即直接授权；其他场景逐条询问
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 34584404-fff5-44e1-8e0f-bbeb91625d43
---

sudo 授权约定（2026-08-25 更新）：

1. **`/ubuntu-system-check` skill（2026-08-25 约定）**：运行前直接提示用户输入 sudo 密码，用户输入即视为对全部 sudo **只读检查**命令的直接授权，经 `sudo -S -v` 缓存后直接执行、不再逐条询问；用户不输入则跳过全部 sudo 命令并在报告中标注。维护动作（升级/清理/重启禁用服务/改防火墙）仍须逐项确认。
2. **其他场景（2026-08-19 约定）**：执行未预先授权的 sudo 命令前，先列出命令和用途，向用户请求确认。用户在对话中直接回复 sudo 密码表示同意（用 `sudo -S` 执行，密码不写入文件、不回显、执行完不保留）；回复 NO 表示拒绝。本机 sudo 需要密码（无 NOPASSWD 配置）。

**Why:** 用户希望 sudo 授权尽量简单——常用检查流程一次授权直接跑完；非常规场景保留询问。
**How to apply:** ubuntu-system-check 按约定 1 执行；其他 sudo 命令按约定 2 执行。可提醒用户自行执行 `sudo -v` 预缓存凭据（约 15 分钟），避免密码进入会话记录。
