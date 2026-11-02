---
name: system-freeze-diagnosis
description: LVpc 机器 2026-09-07 死机根因（内存耗尽假死）与已采取的系统防护措施
metadata: 
  node_type: memory
  type: project
  originSessionId: ea2d810b-bd89-430b-91da-f08841ec2031
---

LVpc（15GB 内存 / 4 核 / Intel HD 630 集显 / 联想本）2026-09-07 07:49–08:02 死机：内存耗尽导致 swap 抖动假死（输入延迟最高 92s），非内核/硬件故障。用户硬断电重启。

**已采取的措施**（2026-09-07）：
- 已安装并启用 earlyoom（内存濒临耗尽时主动杀大户，防再次假死）
- `kernel.sysrq=176`，未开放 `f`（OOM 清理）功能；用户机械键盘无 SysRq 键，急救走 SSH 远程 `echo f > /proc/sysrq-trigger`
- 若用户要求开放 sysrq-f：写 `/etc/sysctl.d/` 设 `kernel.sysrq=240`

**排查参考**：假死特征 = Xorg 日志输入延迟渐进增大 + journald 最后一条 `Under memory pressure, flushing caches` + 内核无 OOM/GPU hang 记录。主要内存大户嫌疑：Chrome（多标签页）。

**2026-09-22 复查**：earlyoom 配置仅 `EARLYOOM_ARGS="-r 3600"`，触发条件为默认 AND（mem≤10% 且 swap≤10%），而本机 swap 全天 0 使用 → 内存耗尽但 swap 未满时 earlyoom 不会开枪，防护偏松。systemd-oomd 只按 PSI 管用户 slice，两者互补无冲突。建议 `-s 0`（忽略 swap）+ `-r 60`，待用户确认。另：NVMe 记录 94 次不安全关机，journal 证实每日 01:10 定时重启均为干净关机 → 不安全关机主要来自市电断电（无电池无 UPS）+ 历史假死硬断电。
