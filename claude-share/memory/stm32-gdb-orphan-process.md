---
name: stm32-gdb-orphan-process
description: STM32CubeIDE/VSCode 调试残留孤儿 gdb 进程满核空转并写爆 /tmp，导致系统卡顿
metadata: 
  node_type: memory
  type: project
  originSessionId: d1d68d00-d369-4ae3-b5d1-a1751b4a1508
---

2026-08-19 排查本机 Ubuntu 卡顿，根因：STM32CubeIDE/VSCode(cortex-debug) 调试会话结束后残留的孤儿 `arm-none-eabi-gdb` 进程（94~100% CPU 空转，4 核机器独占 1 核），同时向 `/tmp/gdb-server-console-*.log` 疯狂写日志（4.4G + 861M），把根分区顶到 85%。处置：`kill -9` 该进程 → 删除日志 → 清理旧内核 6.8.0-137。

**Why:** 用户经常用 STM32CubeIDE 调试（[[mcu-book-project]]），此类残留可能复发。
**How to apply:** 已部署自动清理机制（2026-08-19）：脚本 `~/claudewzp/system_cmd/gdb-watchdog.sh` + systemd 用户定时器 `gdb-watchdog.timer`（每 5 分钟，已实测通过）。判定规则：①无 IDE/调试服务器运行 ②gdb 10 秒内 CPU 时间 >5 秒（空转）。查看状态：`systemctl --user list-timers gdb-watchdog.timer`；清理记录：`journalctl -t gdb-watchdog`。若该机制被禁用/丢失，先 `top -bn1` 查 `arm-none-eabi-gdb` 进程，再查 `/tmp` 下 `gdb-server-console-*.log` 大小。
