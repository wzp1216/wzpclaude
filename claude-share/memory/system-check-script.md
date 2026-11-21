---
name: system-check-script
description: system-check.sh 免进 Claude 执行 ubuntu-system-check 技能：只读检查+日志+复杂/常规判定
metadata: 
  node_type: memory
  type: project
  originSessionId: 7798fa25-17c2-46e5-a584-115c7571f2e9
---

`/media/data/claudewzp/C_sysadmin/system_cmd/system-check.sh` 是 ubuntu-system-check 技能的独立脚本版（2026-11-03 创建）。

**设计约定**：
- 六类只读检查全程 tee 到日志 `~/.local/share/ubuntu-system-check/logs/check-<时间戳>.log`（自动保留最近 20 份）
- 判定规则：出现 ❌（真实失败服务、磁盘≥95%、SMART 异常、dpkg 损坏、ufw 未启用、PermitRootLogin yes、同一错误日志重复≥100 次）→ "情况复杂"，只提示进 Claude，不做任何维护；否则 🟢 常规 → 确认后（`-y` 免确认）执行低风险维护：apt update / 装缺失工具 / autoremove --purge / journal vacuum 7d。不执行 apt upgrade、删旧内核、改防火墙
- 脚本内有本机特例白名单 `BENIGN_UNITS='configure-printer@'`：打印机未连接时的良性失败单元，只标 ⚠️ 不判复杂（与 [[lvpc-system-profile]] 的打印机单元良性报错对应）；**其他机器使用需清空该变量**
- 非 root 运行（禁止 sudo 直接运行，避免日志写进 /root）；sudo 凭据先 `sudo -n` 探测，无则交互提示一次 `sudo -v` 缓存，跳过则相关项标注"未检查"
- 第六节 shell 历史垃圾线索只列 `$HOME` 下的现存路径，不清理

**已取代 checksys.sh**（2026-11-03 用户确认替换后删除；旧脚本无日志、清理含 `rm -rf` 回收站等风险项，勿再提及）。
