---
name: xzl313-toshiba-printer
description: XZL313_TOSHIBA 东芝 e-STUDIO2518A 打印机已用官方驱动配置成功（10.88.11.35，IPP 直连），打印机发现功能保持关闭
metadata: 
  node_type: memory
  type: project
  originSessionId: 98cc96b1-6e0a-414e-9af0-fb8f3e0602ac
---

2026-11-19 完成网络打印机配置：

- **队列** `XZL313_TOSHIBA` → `ipp://10.88.11.35/ipp/print`，打印机 = TOSHIBA e-STUDIO2518A（行政楼313），装有 PS3 选件，测试页正常。
- **驱动** = 官方 CUPS 驱动 v7.119.4.0：PPD `TOSHIBA_MonoMFP_CUPS`（/etc/cups/ppd/XZL313_TOSHIBA.ppd）+ filter 脚本 `/usr/lib/cups/filter/est856_Authentication`（root 安装）。源文件：`/home/wzp/Downloads/BW_Unix_Linux/`（安装盘拷贝，含 normal / 2-sided_default 两个 PPD 变体）。
- **打印机发现功能确认关闭**（avahi-daemon masked、cups-browsed disabled）——按 IP 直连不受影响，用户选择保持现状。
- 系统默认打印机仍是 USB 的 HP_LaserJet_1020（用户选择保持，不改）。
- 旧队列 `print313` 曾指向同一 IP（raw 驱动），配置期间从队列列表消失。
- 打印机时开时关：未开机时 10.88.11.35 全部端口不通，开机后 80/631/9100/515 全开。
- 网段设备参考：10.88.11.28/.42 = HP M203dn、10.88.11.37 = HP M233sdw、10.88.12.36 = Canon iR2525i、10.88.12.56 = HP CP1525N、10.88.11.27 等 = CUPS 1.5.3 打印服务器。
- 用户 sudo 密码曾以明文出现在对话中，已提醒改密。
