#!/bin/bash

# ============================================
# Ubuntu 系统快速健康检查脚本
# 用法: chmod +x syscheck.sh && ./syscheck.sh
# ============================================

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色
BOLD='\033[1m'

# 用于收集主要问题
declare -a CRITICAL_ISSUES=()
declare -a WARNING_ISSUES=()

# 打印带颜色的标题
print_title() {
    echo -e "\n${BLUE}${BOLD}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}════════════════════════════════════════════════════════${NC}\n"
}

# 打印结果
print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNING_ISSUES+=("$1")
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    CRITICAL_ISSUES+=("$1")
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# ============================================
# 1. 系统基本信息
# ============================================
print_title "系统基本信息"

HOSTNAME=$(hostname)
KERNEL=$(uname -r)
OS=$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
UPTIME=$(uptime -p | sed 's/up //')
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)

echo "  主机名: $HOSTNAME"
echo "  操作系统: $OS"
echo "  内核版本: $KERNEL"
echo "  运行时长: $UPTIME"
echo "  平均负载: $LOAD"

# ============================================
# 2. 内存检查
# ============================================
print_title "内存使用情况"

TOTAL_MEM=$(free -h | awk '/^Mem:/ {print $2}')
USED_MEM=$(free -h | awk '/^Mem:/ {print $3}')
AVAIL_MEM=$(free -h | awk '/^Mem:/ {print $7}')
MEM_PERCENT=$(free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')

echo "  总内存: $TOTAL_MEM"
echo "  已用: $USED_MEM"
echo "  可用: $AVAIL_MEM"
echo "  使用率: ${MEM_PERCENT}%"

if [ $MEM_PERCENT -gt 90 ]; then
    print_error "内存使用率超过 90% (${MEM_PERCENT}%)，系统可能卡顿"
elif [ $MEM_PERCENT -gt 75 ]; then
    print_warn "内存使用率较高 (${MEM_PERCENT}%)，建议关注"
else
    print_ok "内存使用正常"
fi

# ============================================
# 3. 磁盘检查
# ============================================
print_title "磁盘使用情况"

df -h --output=target,pcent,used,size | grep -v "tmpfs" | grep -v "snap" | while read line; do
    echo "  $line"
done

# 检查根分区使用率
ROOT_USED=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $ROOT_USED -gt 90 ]; then
    print_error "根分区使用率超过 90% (${ROOT_USED}%)，磁盘空间不足"
elif [ $ROOT_USED -gt 80 ]; then
    print_warn "根分区使用率较高 (${ROOT_USED}%)，建议清理"
else
    print_ok "根分区空间充足 (${ROOT_USED}%)"
fi

# ============================================
# 4. 系统负载检查
# ============================================
print_title "CPU 负载情况"

CPU_CORES=$(nproc)
LOAD1=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs | cut -d'.' -f1)

echo "  CPU 核心数: $CPU_CORES"
echo "  1分钟平均负载: $LOAD1"

if [ $LOAD1 -gt $((CPU_CORES * 2)) ]; then
    print_error "系统负载过高 (${LOAD1} > ${CPU_CORES}*2)，可能有进程阻塞"
elif [ $LOAD1 -gt $CPU_CORES ]; then
    print_warn "系统负载偏高 (${LOAD1} > ${CPU_CORES})，建议关注"
else
    print_ok "系统负载正常"
fi

# ============================================
# 5. 检查僵尸进程
# ============================================
ZOMBIE=$(ps aux | awk '$8=="Z" {print $2}' | wc -l)
if [ $ZOMBIE -gt 0 ]; then
    print_error "发现 ${ZOMBIE} 个僵尸进程 (Zombie)，可能影响系统稳定性"
else
    print_ok "无僵尸进程"
fi

# ============================================
# 6. 检查 failed 的系统服务
# ============================================
print_title "系统服务状态"

FAILED_SERVICES=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED_SERVICES -gt 0 ]; then
    print_error "发现 ${FAILED_SERVICES} 个服务启动失败"
    systemctl --failed --no-legend | while read line; do
        echo "    ❌ $line"
    done
else
    print_ok "所有系统服务运行正常"
fi

# ============================================
# 7. 检查最近的系统错误日志（最近5分钟）
# ============================================
print_title "最近5分钟的错误日志"

ERROR_COUNT=$(journalctl --since "5 minutes ago" -p 3 -o short 2>/dev/null | wc -l)
if [ $ERROR_COUNT -gt 0 ]; then
    print_warn "最近5分钟发现 ${ERROR_COUNT} 条错误日志"
    echo ""
    echo "  📝 最新3条错误:"
    journalctl --since "5 minutes ago" -p 3 -o short 2>/dev/null | tail -3 | while read line; do
        echo "    $line"
    done
else
    print_ok "最近5分钟无错误日志"
fi

# ============================================
# 8. 检查硬件错误 (dmesg)
# ============================================
print_title "硬件/内核异常"

HARDWARE_ERRORS=$(dmesg | grep -iE "error|fail|panic|bug|oops|hardware" | tail -5)
if [ -n "$HARDWARE_ERRORS" ]; then
    print_warn "检测到可能的硬件或内核异常"
    echo "$HARDWARE_ERRORS" | while read line; do
        echo "    $line"
    done
else
    print_ok "无明显的硬件/内核异常"
fi

# ============================================
# 9. 磁盘健康检查 (如果有 smartctl)
# ============================================
if command -v smartctl &> /dev/null; then
    print_title "磁盘健康状态 (SMART)"
    DISK=$(lsblk -d -o NAME,TYPE | grep disk | head -1 | awk '{print "/dev/"$1}')
    if [ -n "$DISK" ] && [ -b "$DISK" ]; then
        SMART_STATUS=$(sudo smartctl -H $DISK 2>/dev/null | grep -i "SMART overall-health" | awk -F':' '{print $2}' | xargs)
        if [ "$SMART_STATUS" == "PASSED" ]; then
            print_ok "磁盘 ${DISK} SMART 健康状态: PASSED"
        elif [ -n "$SMART_STATUS" ]; then
            print_error "磁盘 ${DISK} SMART 状态异常: $SMART_STATUS，请立即备份数据！"
        else
            print_info "无法读取磁盘 ${DISK} SMART 信息（可能需要 sudo 权限）"
        fi
    fi
else
    print_info "未安装 smartctl，跳过磁盘健康检查 (可安装: sudo apt install smartmontools)"
fi

# ============================================
# 10. 检查未更新的安全补丁
# ============================================
print_title "安全更新检查"

if command -v apt &> /dev/null; then
    SECURITY_UPDATES=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l)
    if [ $SECURITY_UPDATES -gt 0 ]; then
        print_warn "有 ${SECURITY_UPDATES} 个安全更新待安装 (建议: sudo apt update && sudo apt upgrade)"
    else
        print_ok "无待安装的安全更新"
    fi
fi

# ============================================
# 11. 网络连接检查
# ============================================
print_title "网络连接状态"

if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
    print_ok "外网连接正常 (ping 8.8.8.8 成功)"
else
    print_error "外网连接失败 (ping 8.8.8.8 超时)"
fi

# ============================================
# 最终汇总报告
# ============================================
print_title "📊 检查结果汇总"

echo -e "\n${BOLD}主要问题列表:${NC}\n"

if [ ${#CRITICAL_ISSUES[@]} -eq 0 ] && [ ${#WARNING_ISSUES[@]} -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}✅ 系统状态良好，未发现明显问题！${NC}\n"
else
    # 先显示严重问题
    if [ ${#CRITICAL_ISSUES[@]} -gt 0 ]; then
        echo -e "  ${RED}${BOLD}【严重问题】${NC}"
        for issue in "${CRITICAL_ISSUES[@]}"; do
            echo -e "    ${RED}✗${NC} $issue"
        done
        echo ""
    fi
    
    # 再显示警告
    if [ ${#WARNING_ISSUES[@]} -gt 0 ]; then
        echo -e "  ${YELLOW}${BOLD}【警告】${NC}"
        for issue in "${WARNING_ISSUES[@]}"; do
            echo -e "    ${YELLOW}⚠${NC} $issue"
        done
        echo ""
    fi
    
    echo -e "  ${BLUE}💡 建议:${NC}"
    echo -e "    1. 优先处理【严重问题】"
    echo -e "    2. 酌情处理【警告】"
    echo -e "    3. 运行 'journalctl -xe' 查看详细日志\n"
fi

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "检查完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}\n"

