#!/bin/bash

# ============================================================
# 代理管理脚本 proxy.sh
# 功能：设置/取消 HTTP/HTTPS/SOCKS 代理（含 git 代理）
# 用法：source proxy.sh {on|off|status|help}
# ============================================================

# ---------- 配置区域（请按需修改）----------
PROXY_HOST="127.0.0.1"          # 代理服务器地址
PROXY_HTTP_PORT="7890"          # HTTP 代理端口
PROXY_SOCKS_PORT="7891"         # SOCKS 代理端口（通常 HTTP 和 SOCKS 端口不同）
# -------------------------------------------

# 组合代理地址
HTTP_PROXY_URL="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
HTTPS_PROXY_URL="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"  # HTTPS 通常也走 HTTP 隧道，如需独立可修改
SOCKS_PROXY_URL="socks5://${PROXY_HOST}:${PROXY_SOCKS_PORT}"

# ---------- 函数定义 ----------

# 显示帮助信息
show_help() {
    cat << EOF
==================================================
  代理管理脚本 proxy.sh - 使用帮助
==================================================

用法:
    source proxy.sh on      # 开启代理
    source proxy.sh off     # 关闭代理
    source proxy.sh status  # 查看当前代理状态
    source proxy.sh help    # 显示此帮助信息

说明:
    1. 此脚本设置以下环境变量：
       http_proxy, https_proxy, all_proxy, no_proxy
       以及大写版本 (HTTP_PROXY, HTTPS_PROXY, ALL_PROXY, NO_PROXY)

    2. Git 代理会同步设置：
       git config --global http.proxy
       git config --global https.proxy
       (关闭代理时会清除这些设置)

    3. 代理配置在脚本开头的"配置区域"中修改：
       PROXY_HOST       - 代理服务器地址 (默认: 127.0.0.1)
       PROXY_HTTP_PORT  - HTTP 代理端口 (默认: 7890)
       PROXY_SOCKS_PORT - SOCKS 代理端口 (默认: 7891)

    4. 请使用 source 命令执行脚本 (否则环境变量不会生效)：
       source proxy.sh on    (或 . proxy.sh on)

    5. no_proxy 默认包含：localhost, 127.0.0.1, ::1, 本机内网IP段

示例:
    source proxy.sh on      # 开启代理
    curl -I google.com      # 测试代理是否生效
    source proxy.sh status  # 查看当前状态
    source proxy.sh off     # 关闭代理

==================================================
EOF
}

# 开启代理
proxy_on() {
    # 设置环境变量（小写）
    export http_proxy="${HTTP_PROXY_URL}"
    export https_proxy="${HTTPS_PROXY_URL}"
    export all_proxy="${SOCKS_PROXY_URL}"
    export no_proxy="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"

    # 设置环境变量（大写，部分程序会用到）
    export HTTP_PROXY="${http_proxy}"
    export HTTPS_PROXY="${https_proxy}"
    export ALL_PROXY="${all_proxy}"
    export NO_PROXY="${no_proxy}"

    # 设置 Git 代理
    git config --global http.proxy "${HTTP_PROXY_URL}"
    git config --global https.proxy "${HTTPS_PROXY_URL}"
    # Git 支持 socks 代理（如需单独设置可以取消下面注释）
    # git config --global socks.proxy "${SOCKS_PROXY_URL}"

    echo "✅ 代理已开启 (HTTP: ${HTTP_PROXY_URL}, SOCKS: ${SOCKS_PROXY_URL})"
    echo "   Git 代理已同步设置"
}

# 关闭代理
proxy_off() {
    # 清除环境变量（小写）
    unset http_proxy
    unset https_proxy
    unset all_proxy
    unset no_proxy

    # 清除环境变量（大写）
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset ALL_PROXY
    unset NO_PROXY

    # 清除 Git 代理
    git config --global --unset http.proxy 2>/dev/null
    git config --global --unset https.proxy 2>/dev/null
    # git config --global --unset socks.proxy 2>/dev/null

    echo "✅ 代理已关闭，环境变量已清除"
    echo "   Git 代理已清除"
}

# 查看状态
proxy_status() {
    echo "==================== 代理状态 ===================="
    
    # 检查并显示各环境变量
    local http_val="${http_proxy:-${HTTP_PROXY:-未设置}}"
    local https_val="${https_proxy:-${HTTPS_PROXY:-未设置}}"
    local all_val="${all_proxy:-${ALL_PROXY:-未设置}}"
    local no_val="${no_proxy:-${NO_PROXY:-未设置}}"
    
    echo "http_proxy  : ${http_val}"
    echo "https_proxy : ${https_val}"
    echo "all_proxy   : ${all_val}"
    echo "no_proxy    : ${no_val}"
    
    # 检查 Git 代理
    echo ""
    echo "--- Git 代理配置 ---"
    local git_http=$(git config --global --get http.proxy 2>/dev/null)
    local git_https=$(git config --global --get https.proxy 2>/dev/null)
    echo "git http.proxy  : ${git_http:-未设置}"
    echo "git https.proxy : ${git_https:-未设置}"

    # 简单连通性检测（如果开启代理则测试）
    if [[ -n "${http_proxy}" ]] || [[ -n "${HTTP_PROXY}" ]]; then
        echo ""
        echo "--- 代理连通性检测 ---"
        local test_url="https://www.google.com"
        if curl -s --connect-timeout 3 -x "${HTTP_PROXY_URL}" "${test_url}" >/dev/null 2>&1; then
            echo "✅ 代理可连通 (测试访问 ${test_url})"
        else
            echo "⚠️  代理无法连通，请检查代理服务是否运行 (测试访问 ${test_url})"
        fi
    fi
    echo "=================================================="
}

# ---------- 主逻辑 ----------

case "$1" in
    on)
        proxy_on
        ;;
    off)
        proxy_off
        ;;
    status)
        proxy_status
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo "❌ 未知命令: $1"
        echo "用法: source proxy.sh {on|off|status|help}"
        echo "使用 'source proxy.sh help' 查看详细帮助"
        return 1 2>/dev/null || exit 1
        ;;
esac

