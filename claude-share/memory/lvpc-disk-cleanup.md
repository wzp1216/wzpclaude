---
name: lvpc-disk-cleanup
description: LVpc 根分区维护记录：空间大户位置、钉钉日志/WPS 备份清理风险、回收站教训
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
**10-20 已做**：全量升级 7 包（含安全更新）、journal vacuum 7d（0B，日志都在 7 天内）、postfix 回环化、清 pip/缩略图/wine 缓存。**无遗留待办**；仅建议：Chrome 关闭时清一次缓存（可省 542M）。

关联：[[lvpc-system-profile]]、[[lvpc-network-security]]
