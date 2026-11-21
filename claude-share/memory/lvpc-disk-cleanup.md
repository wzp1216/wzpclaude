---
name: lvpc-disk-cleanup
description: LVpc 根分区维护记录：空间大户位置、钉钉日志/WPS 备份清理风险、回收站教训、home 目录迁移至 /media/data/wzp-home（符号链接）
metadata: 
  node_type: memory
  type: project
  originSessionId: 73a8da2d-ab3a-4f04-a077-042e60360d74
---

2026-10-19 系统检查与维护，根分区 82% → 77%（47G 盘，剩 11G）。2026-10-20 再检：根分区 76–77%（剩 12G），**全部 7 个可升级包已升级**（含 git/libxtst6 安全更新；xserver 4 包为 phased 更新，需 `-o APT::Get::Always-Include-Phased-Updates=true` 才装上）。postfix 已改 `inet_interfaces = loopback-only`（原监听 0.0.0.0:25）。winehq 源无法连接（apt update 报超时警告，无害）。

**空间大户位置（下次磁盘紧张优先查这些）**：
- 钉钉日志 `~/.config/DingTalk/log/`：每天 40–60M 累积（`dingtalk_*.log` + `gaea.log.日期`），已清至 4.7M。清理时当天文件用 `truncate -s 0`（钉钉进程持有句柄，rm 不释放空间）。
- WPS 自动备份 `~/.local/share/Kingsoft/office6/data/backup/`：每个保存周期生成 78–89M 的 .wps 备份，2.5G 已被用户要求**彻底删除**。风险：WPS 运行时删除会使崩溃自动恢复失效，用户知情选择删除；WPS 后续保存会重新生成备份。
- Chrome 缓存 `~/.cache/google-chrome/`（2026-10-20 已回涨到 542M，Chrome 运行中不可清）、GUI 回收站。
- **不可清**：`~/Downloads`（860M，全是教务工作文档）、`~/.ltspice`（2.4G，LTspice 电路数据）、`~/data`。

**教训**：用户 GUI 回收站里曾装的是教务工作文档（双高佐证、资金明细等），2026-10-19 按用户确认清空后不可恢复。以后建议清空回收站前先列内容给用户过目；工作文档默认跳过。

**10-19 已做**：清旧内核 146（7 个包，剩 147）、journal vacuum（本身 0B 可释放）。
**10-20 已做**：全量升级 7 包（含安全更新）、journal vacuum 7d（0B，日志都在 7 天内）、postfix 回环化、清 pip/缩略图/wine 缓存。

**11-07 已做**：~/.cache 中 4 项移入 `~/.local/share/ubuntu-maintenance-trash/cache-20261107/`（claude-review-chrome 250M、thumbnails 43M、pip 20M、goldendict 12M，共 325M——同分区未真正释放，需清空回收站）；**Chrome 关闭后清空其缓存 1.07G**（Cache/Code Cache/GPUCache/ShaderCache 等纯缓存子目录直接删除，配置资料在 ~/.config/google-chrome 未动），根分区回落至 78%（可用 11G）。**未做**（用户选择暂不）：43 个可升级包（含安全更新）。**待办**：① 用户清空技能回收站 cache-20261107 再释放 325M ② 钉钉 `~/.config/DingTalk/` 共 1.4G（cache 711M + log 460M，log 可安全清）③ apt 源访问慢（首次 update 卡 3 分钟，需每源 8s 超时）。

**11-07 晚 已完成 home→data 迁移**：`~/{Public, Videos, .stmcufinder, STM32Cube, .vscode, .wine, .local/share/stm32cube}`（约 6.3G）已迁至 `/media/data/wzp-home/`，原路径为**符号链接**指向新位置。切换前逐目录 rsync -ain 验证 0 差异。根分区 79% → 65%（释放约 7G）。原执行会话（pts/3）卡在权限确认，任务由另一会话收尾，卡住的会话已终止。注意：后续磁盘统计、备份时这些路径是链接而非真实目录；若 /media/data 未挂载，这些路径会失效。

**11-19 已做**（ubuntu-system-check 检查+维护）：清旧内核 147（7 个包：image/modules/extra/headers×2/tools×2，剩 149，grub 正常仍含 Windows 双启动项）、清空回收站 209M、Chrome **运行时**清其缓存 963M（未重启 Chrome，用户知情）、journal vacuum 7d（0B，日志都在 7 天内，与前两次一致）。根分区 68% → 64%（47G 盘，剩 17G）。**未做**（用户选择暂不）：51 个可升级包（含 21 安全更新，gstreamer/hplip 系）。**仍待办**：钉钉 ~/.config/DingTalk 1.6G（建议钉钉内清理）、Chrome 缓存会再涨（约每月 1G）。**检查侧记**：USB 1-3.2/1-3.3 枚举错误反复出现（非致命）；sudo 时间戳不跨 Bash 调用共享（每次需 `echo 密码 | sudo -S` 或同调用内 -v 后执行）。

关联：[[lvpc-system-profile]]、[[lvpc-network-security]]
