---
name: lvpc-system-profile
description: LVpc 机器基本盘信息——双系统 Windows、已卸载 Docker、LTspice 走 wine、打印机单元良性报错
metadata: 
  node_type: memory
  type: project
  originSessionId: 44081eb2-c633-4a93-a917-68357971a5a2
---

LVpc（Ubuntu 24.04.5，用户 wzp）机器画像，2026-10-06 系统体检确认：

- **Windows 双系统**：Windows Boot Manager 在 nvme0n1p3（UEFI）。双系统 RTC 时区解读不一致会致开机后时钟回跳 8 小时，NTP 同步后自动纠正——日志时间戳异常时先想到这个，勿误判为故障。
- **Docker 已于 2026-10-06 卸载**（用户确认不用；此前自 2025-07 起就未使用）。
- **LTspice 通过 wine 安装**（`~/.ltspice` 2.4G），安装包 `~/LTspice64.msi` 已清理（2026-10-24 体检确认不存在）。
- **cloud-init 已禁用**（2026-10-24，桌面机冗余，5 个单元全 disable）：下次体检看到 cloud-init 相关服务 inactive 属正常，勿当异常。livepatch snap 旧版本 414 已清，仅留 418。
- **打印机失败单元**：`configure-printer@usb-001-002.service` 为开机时 udev 配置竞态（"Device already handled"），无害，打印机（usb 1-1，usblp）正常工作。
- 相关维护历史见 [[system-freeze-diagnosis]]（内存耗尽防护）、[[lvpc-network-security]]（ufw/fail2ban 加固）。
