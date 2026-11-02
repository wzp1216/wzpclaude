---
name: lvpc-network-security
description: LVpc 网络安全加固（2026-09-14 实施；09-22 复查发现 fail2ban/ufw 封禁/SSH 密码认证三项实际失效，修复待用户确认）
metadata: 
  node_type: memory
  type: project
  originSessionId: 4375b680-b3ca-414c-b1aa-f10f3371200f
---

2026-09-14 系统检查发现：SSH 遭局域网暴力破解（11 天 29553 次失败，来源 192.168.16.203 / 10.104.125.103 等校园网段），当时防火墙未启用（ufw inactive）。已执行：

- **ufw 已启用**：默认拒绝入站，放行 22/tcp，封禁 3 个攻击 IP（192.168.16.203、10.104.125.103、10.104.125.106）。RDP 3389/3390、postfix 25 保持封锁
- **远程桌面决策（2026-09-14）**：用户选择 SSH 隧道方案（Windows 侧 `ssh -N -L 13389:localhost:3389 wzp@<IP>`，mstsc 连 localhost:13389），**3389 不对网络开放**——不要建议 ufw 放行 3389。SSH 目前用密码认证，用户计划后续自行加固（密钥登录）
- **fail2ban 已安装**，sshd jail 生效。**关键修正**：本机 SSH 为 socket 激活，失败日志挂在 `ssh.service` 而非 `sshd.service` 单元，出厂配置抓不到 → 已写 `/etc/fail2ban/jail.d/sshd-socket.local`（`journalmatch = _SYSTEMD_UNIT=ssh.service`）
- 机器在校园网内，攻击面长期暴露；重装系统后需重新执行以上加固
- **syslog 刷屏元凶是钉钉（2026-09-17 修复）**：钉钉桌面端每 0.5s 写一条 INFO 日志，占 syslog 92.6%（55 万行/112M）。用户曾误以为是 ufw 拦截日志——实际 ufw 已是 `low` 级、量仅 12K。修复：`/etc/rsyslog.d/20-dingtalk.conf` 写入 `:programname, isequal, "com.alibabainc.dingtalk.desktop" stop` 并重启 rsyslog。journald 中钉钉日志仍保留（有大小上限）。ufw 保持 `low` 勿调 off（拦截审计依据）

**2026-09-22 深度复查（fan-out 6 子代理）——发现 3 项防护实际失效，修复待用户确认**：
- **fail2ban 形同虚设**：bantime=600/maxretry=5，且 root crontab 每日 01:10 `shutdown -h now` 导致封禁状态每日清零 → Total banned 一直为 0。journalmatch 修正本身有效（9/19 的 2.0.1.9 失败被正确计数）。9/14 的"攻击"实为本机自测（attacker_1..6 用户名 + 事后手动 unban）。建议 jail.local：bantime=86400、maxretry=3、bantime.increment=true
- **ufw 3 条 DENY 规则从未生效**：`ACCEPT 22` 排在 3 条 `DROP` 之前，iptables 首匹配即生效 → 封禁 IP 实际仍可访问 22 端口。修法：`ufw insert 1 deny from <IP>`
- **SSH 对 wzp 保留密码认证**：sshd_config 末尾有 `Match User wzp / PasswordAuthentication yes` 豁免块（全局为 no），是当前唯一薄弱环节。9/19 密码登录来源 2.0.1.4/.9/.10 公网 IP，特征像用户本人，待确认
- **gnome-remote-desktop 双实例**：系统级 3389 + 用户级 3390 均 enabled+active 且 Linger=yes，常驻监听，仅靠 ufw 单层挡
- 无入侵迹象：无 root 登录尝试、无账号异动、authorized_keys 4 个全为本人设备、postfix 无开放中继、openvpn 为空壳

相关：[[system-freeze-diagnosis]]
