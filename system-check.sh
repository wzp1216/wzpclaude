#!/usr/bin/env bash
# ============================================================
# system-check.sh — Ubuntu 系统检查与常规维护
# 对应 Claude Skill: /ubuntu-system-check
# （~/.claude/skills/ubuntu-system-check/SKILL.md）
#
# 用法:
#   ./system-check.sh       执行只读检查；情况简单时询问后执行常规维护
#   ./system-check.sh -y    同上，但不询问，直接执行常规维护
#
# 行为:
#   1. 六类只读检查全部执行，过程实时写入日志文件
#   2. 汇总判定:
#      - 情况复杂（存在 ❌ 级问题）→ 不做任何维护，提示进入 Claude 处理
#      - 情况常规 → 执行低风险维护（刷新软件列表 / 安装缺失的检查工具 /
#        autoremove 无用依赖 / 清理 7 天前日志），确认后（或 -y）执行
#   3. 本脚本不执行: apt upgrade、删除旧内核、改防火墙、禁用服务、
#      清理用户文件（shell 历史垃圾线索仅记录，交由 Claude 确认）
#
# 日志: ~/.local/share/ubuntu-system-check/logs/check-<时间戳>.log
#       自动保留最近 20 份
#
# sudo: 先尝试免密（凭据已缓存）；否则交互提示输入一次密码并缓存；
#       用户跳过时，需要 sudo 的项目标注"未检查（无 sudo 权限）"
# ============================================================

[ -n "${BASH_VERSION:-}" ] || { echo "请用 bash 运行: bash $0" >&2; exit 1; }
set -u

# 禁止以 root 直接运行（sudo 由脚本内部按需使用，避免日志写到 /root）
[ "$(id -u)" -eq 0 ] && { echo "请以普通用户身份运行本脚本（需要权限时脚本会提示 sudo 密码）" >&2; exit 1; }

AUTO=0
case "${1:-}" in -y|--yes) AUTO=1;; esac

TS=$(date +%Y%m%d-%H%M%S)
LOG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/ubuntu-system-check/logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/check-$TS.log"
ls -1t "$LOG_DIR"/check-*.log 2>/dev/null | tail -n +21 | xargs -r rm -f

# 全部输出同时进入终端与日志
exec > >(tee -a "$LOG") 2>&1

echo "============================================================"
echo " Ubuntu 系统检查  $(date '+%F %T')  主机: $(hostname)"
echo " 日志文件: $LOG"
echo "============================================================"

# ---------- sudo 预授权 ----------
SUDO_OK=0
if sudo -n true 2>/dev/null; then
    SUDO_OK=1
elif [ -t 0 ]; then
    echo
    echo "部分检查需要 sudo（apt 更新 / SMART / dmesg / ufw / 登录审计）。"
    read -r -p "现在输入 sudo 密码（用于缓存凭据）？[y/N] " ANS
    case "$ANS" in y|Y) sudo -v 2>/dev/null && SUDO_OK=1;; esac
fi
if [ "$SUDO_OK" = 1 ]; then
    S="sudo"
else
    S=""
    echo "⚠️ 无 sudo 权限，相关项目将标注为未检查。"
fi

# ---------- 汇总状态 ----------
COMPLEX=0
ISSUE_CNT=0
issue() { printf '  %s %s\n' "$1" "$2"; ISSUE_CNT=$((ISSUE_CNT+1)); [ "$1" = "❌" ] && COMPLEX=1; }
say() { echo; echo "===== $1 ====="; }

# ============================================================
say "一、系统基础"
lsb_release -a 2>/dev/null || cat /etc/os-release
uname -r
uptime
nproc
free -h
df -hT

CORES=$(nproc)
LOAD1=$(awk '{print $1}' /proc/loadavg); LOAD1=${LOAD1:-0}
MEM_AVAIL_MB=$(free -m | awk '/^Mem:/ {print $7+0}'); MEM_AVAIL_MB=${MEM_AVAIL_MB:-0}
MEM_TOTAL_MB=$(free -m | awk '/^Mem:/ {print $2+0}'); MEM_TOTAL_MB=${MEM_TOTAL_MB:-0}
SWAP_USED_MB=$(free -m | awk '/^Swap:/ {print $3+0}'); SWAP_USED_MB=${SWAP_USED_MB:-0}
ROOT_USE=$(df -P / 2>/dev/null | awk 'NR==2 {sub(/%/,"",$5); print $5+0}'); ROOT_USE=${ROOT_USE:-0}
HOME_USE=$(df -P "$HOME" 2>/dev/null | awk 'NR==2 {sub(/%/,"",$5); print $5+0}'); HOME_USE=${HOME_USE:-0}

# ============================================================
# 本机已知良性失败单元（仅本机特例，其他机器请清空此变量）:
# configure-printer@* —— 打印机未连接时热插拔配置必然失败，属正常现象
BENIGN_UNITS='configure-printer@'
say "二、服务与日志"
FAILED=-1
REAL_FAILED=0
BENIGN_FAILED=0
if systemctl --failed --no-pager >/dev/null 2>&1; then
    FAILED=$(systemctl --failed --no-legend --plain 2>/dev/null | wc -l)
    while read -r u; do
        case "$u" in
            "$BENIGN_UNITS"*) BENIGN_FAILED=$((BENIGN_FAILED+1));;
            "") ;;
            *) REAL_FAILED=$((REAL_FAILED+1));;
        esac
    done <<< "$(systemctl --failed --no-legend --plain 2>/dev/null)"
fi
systemctl --failed --no-pager 2>&1
RUNNING=$(systemctl list-units --type=service --state=running --no-legend --no-pager 2>/dev/null | wc -l)
systemctl list-units --type=service --state=running --no-pager 2>/dev/null | head -30

JOURNAL_OK=0
$S journalctl -n 1 >/dev/null 2>&1 && JOURNAL_OK=1
if [ "$JOURNAL_OK" = 1 ]; then
    $S journalctl -p err -b --no-pager 2>/dev/null | tail -30
    ERR_COUNT=$($S journalctl -p err -b --no-pager 2>/dev/null | wc -l)
    TOP_ERR=$($S journalctl -p err -b --no-pager 2>/dev/null | sed -E 's/^[^ ]+ [^ ]+ //' | sort | uniq -c | sort -rn | head -1 | awk '{print $1+0}')
    $S journalctl -p warning -b --no-pager 2>/dev/null | tail -20
else
    ERR_COUNT=-1; TOP_ERR=0
    echo "⚠️ 当前用户无权读取 journal 日志"
fi
ERR_COUNT=${ERR_COUNT:-0}; TOP_ERR=${TOP_ERR:-0}
systemd-analyze 2>/dev/null || echo "⚠️ systemd-analyze 不可用"
systemd-analyze blame 2>/dev/null | head -10
systemctl list-unit-files --state=enabled --no-pager 2>/dev/null | head -40

# ============================================================
say "三、更新与软件包"
if [ "$SUDO_OK" = 1 ]; then
    sudo apt-get update -qq 2>&1 | tail -3
    [ "${PIPESTATUS[0]}" -ne 0 ] && echo "⚠️ apt-get update 失败"
else
    echo "⚠️ 未执行 apt-get update（无 sudo），以下可升级清单基于缓存（可能过期）"
fi
UPG=$(apt list --upgradable 2>/dev/null | grep -c upgradable); UPG=${UPG:-0}
SEC_UPG=$(apt list --upgradable 2>/dev/null | grep -ci security); SEC_UPG=${SEC_UPG:-0}
apt list --upgradable 2>/dev/null | tail -40
echo "--- dpkg --audit ---"
dpkg --audit
AUDIT=$(dpkg --audit 2>/dev/null | wc -l); AUDIT=${AUDIT:-0}
$S apt-get check 2>&1 | tail -3
echo "--- 已安装内核 ---"
dpkg -l 'linux-image-*' 2>/dev/null | awk '/^ii/ {print $2}'
echo "--- autoremove 预览（仅模拟，不执行） ---"
apt-get -s autoremove 2>/dev/null | tail -15
AUTO_REMOVE=$(apt-get -s autoremove 2>/dev/null | awk '/^Remv/{n++} END{print n+0}'); AUTO_REMOVE=${AUTO_REMOVE:-0}

# ============================================================
say "四、硬件与磁盘健康"
SMART_BAD=0
if command -v smartctl >/dev/null 2>&1; then
    DISKS=$(lsblk -dn -o NAME,TYPE 2>/dev/null | awk '$2=="disk"{print "/dev/"$1}')
    if [ -n "$DISKS" ]; then
        for d in $DISKS; do
            echo "--- $d ---"
            OUT=$($S smartctl -H "$d" 2>/dev/null)
            if echo "$OUT" | grep -q "SMART overall-health"; then
                echo "$OUT"
                echo "$OUT" | grep -q "PASSED" || SMART_BAD=1
            else
                echo "⚠️ 无法读取（无 sudo 权限或设备不支持）"
            fi
            BAD_ATTR=$($S smartctl -a "$d" 2>/dev/null | awk '/Reallocated_Sector_Ct|Current_Pending_Sector/ && $10+0>0')
            if [ -n "$BAD_ATTR" ]; then echo "$BAD_ATTR"; SMART_BAD=1; fi
        done
    fi
else
    echo "未安装 smartmontools（可用: sudo apt-get install smartmontools）"
fi
sensors 2>/dev/null || echo "未安装 lm-sensors（可用: sudo apt-get install lm-sensors）"
upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep -E 'state|percentage|time to' || echo "无电池设备（台式机）"
echo "--- dmesg 硬件相关错误 ---"
$S dmesg 2>/dev/null | grep -iE 'error|fail|thermal|i/o' | tail -20
[ "${PIPESTATUS[0]}" -ne 0 ] && echo "⚠️ 无权限读取 dmesg"

# ============================================================
say "五、网络与安全"
$S ss -tulpn 2>/dev/null | grep LISTEN || echo "ss 不可用"
echo "--- 防火墙 ---"
UFW_INACTIVE=0
if command -v ufw >/dev/null 2>&1; then
    UFWS=$($S ufw status 2>/dev/null)
    if [ -n "$UFWS" ]; then
        echo "$UFWS"
        echo "$UFWS" | grep -q "Status: inactive" && UFW_INACTIVE=1
    else
        echo "⚠️ 未检查 ufw 状态（无 sudo 权限）"
    fi
else
    echo "未安装 ufw"
fi
echo "--- 安全相关服务状态 ---"
systemctl is-active ufw fail2ban ssh ssh.socket 2>/dev/null
who
echo "--- 近期登录 ---"
last -n 5
echo "--- 失败登录记录 ---"
$S lastb -n 10 2>/dev/null || echo "无失败登录记录（或需权限）"
echo "--- SSH 关键配置 ---"
SSHD_T=$($S sshd -T 2>/dev/null)
ROOTLOGIN_BAD=0
if [ -n "$SSHD_T" ]; then
    echo "$SSHD_T" | grep -E '^permitrootlogin|^passwordauthentication|^port'
    echo "$SSHD_T" | grep -qi '^permitrootlogin yes' && ROOTLOGIN_BAD=1
else
    grep -viE '^#|^$' /etc/ssh/sshd_config 2>/dev/null | grep -E 'PermitRootLogin|PasswordAuthentication|^Port'
    grep -qiE '^\s*PermitRootLogin\s+yes' /etc/ssh/sshd_config 2>/dev/null && ROOTLOGIN_BAD=1
fi

# ============================================================
say "六、shell 历史中的垃圾文件线索（仅记录，不清理；清理请进 Claude 确认）"
HISTS=~/.bash_history
[ -f ~/.zsh_history ] && HISTS="$HISTS ~/.zsh_history"
CLUES=$(grep -hE 'wget |curl .*(-o|-O)|tar .*x|unzip |7z x|make |cmake |ninja |go build|npm install|pnpm install|pip[0-9]* install|git clone|\.pre-update|\.bak|\.tmp' $HISTS 2>/dev/null | tail -40)
if [ -n "$CLUES" ]; then
    echo "$CLUES"
    echo "--- 线索中当前仍存在于 $HOME 下的路径（仅供参考） ---"
    printf '%s\n' "$CLUES" | grep -hoE '~?/[^ ;|"&<>]*' | sed "s|^~|$HOME|" | sort -u | while read -r p; do
        case "$p" in "$HOME"/*) ;; *) continue;; esac
        [ -e "$p" ] || continue
        du -sh "$p" 2>/dev/null
    done | sort -rh | head -15
else
    echo "未发现明显线索"
fi

# ============================================================
echo
echo "================ 检查汇总 ================="
echo "关键指标: 负载 $LOAD1/${CORES}核 | 内存可用 ${MEM_AVAIL_MB}M/${MEM_TOTAL_MB}M | SWAP 已用 ${SWAP_USED_MB}M | / 使用 ${ROOT_USE}% | $HOME 使用 ${HOME_USE}%"
[ "$RUNNING" -gt 0 ] && echo "运行中服务: $RUNNING 个"
[ "$FAILED" -ge 0 ] && echo "失败服务: $FAILED 个"
[ "$ERR_COUNT" -ge 0 ] && echo "本次启动错误日志: $ERR_COUNT 条（最高单条重复 $TOP_ERR 次）"
echo "可升级包: $UPG 个（其中安全更新 $SEC_UPG 个）"

echo
[ "$FAILED" -eq -1 ] && issue "⚠️" "无法读取 systemd 状态（systemctl 不可用）"
[ "$REAL_FAILED" -gt 0 ] && issue "❌" "有 $REAL_FAILED 个失败的服务/单元（见上方 systemctl --failed）"
[ "$BENIGN_FAILED" -gt 0 ] && issue "⚠️" "已知良性失败单元 $BENIGN_FAILED 个（configure-printer@*，打印机未连接时的正常现象）"
[ "$AUDIT" -gt 0 ] && issue "❌" "dpkg --audit 发现 $AUDIT 条损坏包记录"
[ "$ROOT_USE" -ge 95 ] && issue "❌" "根分区使用率 $ROOT_USE% ≥ 95%"
[ "$ROOT_USE" -ge 85 ] && [ "$ROOT_USE" -lt 95 ] && issue "⚠️" "根分区使用率 $ROOT_USE% 偏高（≥85%）"
[ "$HOME_USE" -ge 95 ] && issue "❌" "家目录分区使用率 $HOME_USE% ≥ 95%"
[ "$HOME_USE" -ge 85 ] && [ "$HOME_USE" -lt 95 ] && issue "⚠️" "家目录分区使用率 $HOME_USE% 偏高（≥85%）"
[ "$SMART_BAD" = 1 ] && issue "❌" "磁盘 SMART 健康异常（见上方详情，建议尽快备份数据）"
[ "$UFW_INACTIVE" = 1 ] && issue "❌" "ufw 防火墙未启用"
[ "$ROOTLOGIN_BAD" = 1 ] && issue "❌" "SSH 允许 root 密码登录（PermitRootLogin yes）"
[ "$TOP_ERR" -ge 100 ] && issue "❌" "同一错误日志本次启动重复 $TOP_ERR 次，需排查"
[ "$ERR_COUNT" -ge 200 ] && issue "⚠️" "本次启动错误日志较多（$ERR_COUNT 条）"
[ "$SEC_UPG" -gt 0 ] && issue "⚠️" "有 $SEC_UPG 个安全更新待安装（本脚本不自动升级，建议进 Claude 确认或手动 sudo apt upgrade）"
[ "$UPG" -gt 0 ] && [ "$SEC_UPG" -eq 0 ] && issue "⚠️" "有 $UPG 个可升级包"
[ "$SWAP_USED_MB" -gt 2048 ] && issue "⚠️" "SWAP 占用 ${SWAP_USED_MB}M，偏高"
awk -v a="$MEM_AVAIL_MB" -v t="$MEM_TOTAL_MB" 'BEGIN{exit !(t>0 && a < t*0.1)}' && issue "⚠️" "可用内存低于总量 10%"
awk -v l="$LOAD1" -v c="$CORES" 'BEGIN{exit !(l > c*0.7)}' && issue "⚠️" "负载 $LOAD1 高于 ${CORES} 核的 70%"
[ "$ISSUE_CNT" -eq 0 ] && echo "✅ 未发现异常"

# ============================================================
echo
if [ "$COMPLEX" = 1 ]; then
    echo "🔴 判定: 情况复杂，本脚本不做任何维护动作。"
    echo "👉 请进入 Claude Code 处理:"
    echo "    1. 在终端执行 claude"
    echo "    2. 执行 /ubuntu-system-check（可引用本次日志）"
    echo "    📄 日志: $LOG"
else
    echo "🟢 判定: 状态常规。"
    ACTS=()
    [ "$SUDO_OK" = 1 ] && ACTS+=("sudo apt-get update（刷新软件列表）")
    MISSING=""
    command -v smartctl >/dev/null 2>&1 || MISSING="$MISSING smartmontools"
    command -v sensors >/dev/null 2>&1 || MISSING="$MISSING lm-sensors"
    [ -n "$MISSING" ] && [ "$SUDO_OK" = 1 ] && ACTS+=("sudo apt-get install -y$MISSING（安装缺失的检查工具）")
    [ "$AUTO_REMOVE" -gt 0 ] && [ "$SUDO_OK" = 1 ] && ACTS+=("sudo apt-get autoremove --purge（移除 $AUTO_REMOVE 个无用依赖）")
    [ "$SUDO_OK" = 1 ] && ACTS+=("sudo journalctl --vacuum-time=7d（清理 7 天前日志）")
    if [ ${#ACTS[@]} -eq 0 ]; then
        echo "无 sudo 权限，跳过常规维护。重跑本脚本并输入 sudo 密码即可。"
    else
        echo "常规维护动作:"
        for i in "${!ACTS[@]}"; do printf '  %d) %s\n' "$((i+1))" "${ACTS[$i]}"; done
        DO=0
        if [ "$AUTO" = 1 ]; then
            DO=1
        else
            read -r -p "确认执行以上维护？[y/N] " ANS
            case "$ANS" in y|Y) DO=1;; esac
        fi
        if [ "$DO" = 1 ]; then
            echo
            sudo apt-get update -qq && echo "✅ apt 软件列表已刷新" || echo "❌ apt update 失败"
            [ -n "$MISSING" ] && sudo apt-get install -y $MISSING
            [ "$AUTO_REMOVE" -gt 0 ] && sudo apt-get autoremove --purge -y
            sudo journalctl --vacuum-time=7d
            echo "✅ 常规维护完成"
        else
            echo "已跳过维护。"
        fi
    fi
fi
echo
echo "📄 完整日志: $LOG"
