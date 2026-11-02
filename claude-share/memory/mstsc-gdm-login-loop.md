---
name: mstsc-gdm-login-loop
description: "mstsc 断开后 xrdp 会话存活导致 GDM 本地登录循环（\"Couldn't find session for user\"），2026-11-02 首现"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1cb341cc-f992-4f52-9f41-5b8ae078b436
---

2026-11-02：用户 mstsc 远程（12:56 登录 → 14:32 直接断开客户端）后，xrdp 会话（display :10，XFCE + Wine/LTSpice）仍存活（sesman.ini `KillDisconnected=false`）。回家后本地 GDM 登录 4 次全失败（会话 68/69/70/71 建立后 14–61 秒被终止），GDM 刷屏 `Couldn't find session for user`，15:43 从登录界面电源菜单手动重启后恢复。

**根因**：GDM 已知 bug（GNOME/gdm issue #1056、Cendio bug 8797）——GDM 经 logind 发现用户已有会话（xrdp 的），试图解锁/强制停止时只查自己内部会话列表，xrdp 会话不在其中 → 报错并中止新登录。与内存无关（全程 available 85%，无 OOM）。

**冲突是双向的**：本地图形会话存在时 mstsc 登录也会冲突——用户已知此规律，外出前会先本地注销（当日 12:48 的注销即为此，非故障）。故用户 mstsc 习惯：先注销本地 → 远程使用 → 关 mstsc。

**无需重启的恢复**：TTY（Ctrl+Alt+F3）或 SSH 登录后 `loginctl list-sessions` → `loginctl terminate-session <xrdp会话号>`，回 GDM 即可登录。

**预防（已于 2026-11-02 实施）**：/etc/xrdp/sesman.ini `[SessionVariables]` 已设 `KillDisconnected=true`（备份 sesman.ini.bak-20261102），关闭 mstsc 即杀远程会话（LTSpice 未保存会丢，提醒用户先保存再断开）。

注意与 [[system-freeze-diagnosis]] 区分：那是内存耗尽假死，本次是 GDM/xrdp 会话冲突。另见 [[lvpc-system-profile]]。
