#!/bin/bash

##############################################################################
# Debian/Ubuntu 初始化脚本
# 用途：配置静态网络 + 启用 root SSH 登录
# 使用: curl -fsSL https://example.com/init-debian.sh | sudo bash
# 参数: init-debian.sh [iface] [ip] [gateway] [dns1] [dns2]
##############################################################################

set -euo pipefail

# 检测是否有 TTY（用于判断是否可以交互）
HAS_TTY=false
if [[ -t 0 ]]; then
    HAS_TTY=true
fi

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否以root运行
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本必须以 root 身份运行"
        exit 1
    fi
}

# 检查系统是否为Debian/Ubuntu
check_system() {
    if [[ ! -f /etc/debian_version ]]; then
        log_error "此脚本仅支持Debian/Ubuntu系统"
        exit 1
    fi
    log_info "检测到Debian/Ubuntu系统"
}

# 获取网络接口列表
get_network_interfaces() {
    local interfaces=()
    for iface in /sys/class/net/*/; do
        if [[ -d "$iface" ]]; then
            interfaces+=("$(basename "$iface")")
        fi
    done
    echo "${interfaces[@]}"
}

# 检测网络配置方式
detect_network_manager() {
    if command -v netplan &> /dev/null && [[ -d /etc/netplan ]]; then
        echo "netplan"
    elif command -v ifup &> /dev/null && [[ -d /etc/network/interfaces.d ]]; then
        echo "ifupdown"
    else
        echo "unknown"
    fi
}

# 配置Netplan静态网络
configure_netplan() {
    local iface=$1
    local ip=$2
    local gateway=$3
    local dns1=${4:-8.8.8.8}
    local dns2=${5:-8.8.4.4}
    
    log_info "使用 netplan 配置网络接口: $iface"
    
    cat > /etc/netplan/00-static-ip.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $iface:
      dhcp4: false
      addresses:
        - $ip/24
      gateway4: $gateway
      nameservers:
        addresses: [$dns1, $dns2]
EOF
    
    chmod 644 /etc/netplan/00-static-ip.yaml
    netplan apply
    log_info "netplan 配置已应用"
}

# 配置ifupdown静态网络
configure_ifupdown() {
    local iface=$1
    local ip=$2
    local gateway=$3
    local dns1=${4:-8.8.8.8}
    local dns2=${5:-8.8.4.4}
    
    log_info "使用 ifupdown 配置网络接口: $iface"
    
    cat > /etc/network/interfaces.d/99-static-ip <<EOF
auto $iface
iface $iface inet static
    address $ip
    netmask 255.255.255.0
    gateway $gateway
    dns-nameservers $dns1 $dns2
EOF
    
    chmod 644 /etc/network/interfaces.d/99-static-ip
    ifup $iface 2>/dev/null || true
    log_info "ifupdown 配置已应用"
}

# 配置静态网络
configure_network() {
    local iface=$1
    local ip=$2
    local gateway=$3
    local dns1=${4:-8.8.8.8}
    local dns2=${5:-8.8.4.4}
    
    local network_manager=$(detect_network_manager)
    
    case "$network_manager" in
        netplan)
            configure_netplan "$iface" "$ip" "$gateway" "$dns1" "$dns2"
            ;;
        ifupdown)
            configure_ifupdown "$iface" "$ip" "$gateway" "$dns1" "$dns2"
            ;;
        *)
            log_error "无法检测到支持的网络配置工具"
            return 1
            ;;
    esac
}

# 启用Root SSH登录
enable_root_ssh() {
    log_info "配置 SSH 以允许 root 登录"
    
    # 备份原始配置
    if [[ ! -f /etc/ssh/sshd_config.bak ]]; then
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        log_info "已备份原始 sshd_config"
    fi
    
    # 注释掉禁用root登录if存在
    sed -i 's/^PermitRootLogin no/#PermitRootLogin no/g' /etc/ssh/sshd_config
    
    # 确保PermitRootLogin yes存在
    if ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
        echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    fi
    
    # 关闭密钥认证要求（可选）
    # sed -i 's/^PubkeyAuthentication no/#PubkeyAuthentication no/g' /etc/ssh/sshd_config
    
    # 验证配置语法
    if sshd -t &> /dev/null; then
        systemctl restart ssh || systemctl restart sshd
        log_info "SSH 服务已重启，root 登录已启用"
    else
        log_error "SSH 配置有错误，未重启服务"
        return 1
    fi
}

# 生成SSH密钥（可选）
generate_ssh_keys() {
    local root_home="/root"
    local ssh_dir="$root_home/.ssh"
    
    if [[ ! -d "$ssh_dir" ]]; then
        mkdir -p "$ssh_dir"
        chmod 700 "$ssh_dir"
    fi
    
    if [[ ! -f "$ssh_dir/id_rsa" ]]; then
        log_info "为 root 用户生成 SSH 密钥"
        ssh-keygen -t rsa -b 4096 -f "$ssh_dir/id_rsa" -N "" -C "root@$(hostname)"
        chmod 600 "$ssh_dir/id_rsa"
        chmod 644 "$ssh_dir/id_rsa.pub"
        log_info "SSH 密钥已生成: $ssh_dir/id_rsa"
    fi
}

# 更新系统
update_system() {
    log_info "更新系统包列表"
    apt-get update
    log_info "升级系统变化（可选，已注释）"
    # apt-get upgrade -y
}

# 安装基础工具（可选）
install_tools() {
    log_info "安装基础工具"
    apt-get install -y \
        curl \
        wget \
        vim \
        git \
        net-tools \
        netplan.io 2>/dev/null || true
    
    log_info "基础工具安装完成"
}

# 获取推荐的网络接口（排除lo，优先选择UP状态的接口）
get_recommended_interface() {
    local interfaces=()
    local recommended=""
    
    # 获取所有非lo接口
    while IFS= read -r line; do
        local iface=$(echo "$line" | awk '{print $2}' | sed 's/://g')
        local state=$(echo "$line" | grep -o 'state [A-Z]*' | awk '{print $2}')
        
        if [[ "$iface" != "lo" ]]; then
            interfaces+=("$iface")
            # 优先推荐UP状态的接口
            if [[ "$state" == "UP" ]] && [[ -z "$recommended" ]]; then
                recommended="$iface"
            fi
        fi
    done < <(ip link show | grep "^[0-9]:")
    
    # 如果没有UP状态的接口，就推荐第一个
    if [[ -z "$recommended" ]] && [[ ${#interfaces[@]} -gt 0 ]]; then
        recommended="${interfaces[0]}"
    fi
    
    echo "$recommended"
}

# 显示网络接口（带状态）
show_interfaces() {
    echo ""
    log_info "系统网络接口："
    
    while IFS= read -r line; do
        local iface=$(echo "$line" | awk '{print $2}' | sed 's/://g')
        local state=$(echo "$line" | grep -o 'state [A-Z]*' | awk '{print $2}')
        
        if [[ "$iface" != "lo" ]]; then
            if [[ "$state" == "UP" ]]; then
                echo -e "  ${GREEN}✓${NC} $iface (状态: $state)"
            else
                echo -e "  ${YELLOW}○${NC} $iface (状态: $state)"
            fi
        fi
    done < <(ip link show | grep "^[0-9]:")
    
    echo ""
}

# 交互式配置
interactive_setup() {
    show_interfaces
    
    # 获取推荐的网络接口
    local recommended=$(get_recommended_interface)
    
    if [[ -z "$recommended" ]]; then
        log_error "无法找到可用的网络接口，请使用命令行参数模式"
        return 1
    fi
    
    # 如果没有 TTY（非交互模式），使用推荐值和默认 IP
    if [[ "$HAS_TTY" == "false" ]]; then
        log_warn "检测到非交互模式（如通过管道或 SSH 执行），使用自动配置"
        log_info "推荐网卡: ${GREEN}$recommended${NC}"
        log_info "使用默认 IP: 192.168.1.100/24"
        configure_network "$recommended" "192.168.1.100" "192.168.1.1" "8.8.8.8" "8.8.4.4"
        return 0
    fi
    
    # 交互模式
    log_info "推荐使用网卡: ${GREEN}$recommended${NC}"
    read -p "请输入要配置的网络接口（直接回车使用推荐: $recommended）: " iface
    iface=${iface:-$recommended}  # 如果用户直接回车，使用推荐值
    
    if [[ -z "$iface" ]]; then
        log_error "网络接口不能为空"
        return 1
    fi
    
    # 验证接口是否存在
    if ! ip link show "$iface" &>/dev/null; then
        log_error "网络接口 $iface 不存在"
        return 1
    fi
    
    read -p "请输入静态IP（如：192.168.1.10）: " ip
    if [[ -z "$ip" ]]; then
        log_error "IP不能为空"
        return 1
    fi
    
    read -p "请输入网关（如：192.168.1.1）: " gateway
    if [[ -z "$gateway" ]]; then
        log_error "网关不能为空"
        return 1
    fi
    
    read -p "请输入DNS1（默认：8.8.8.8）: " dns1
    dns1=${dns1:-8.8.8.8}
    
    read -p "请输入DNS2（默认：8.8.4.4）: " dns2
    dns2=${dns2:-8.8.4.4}
    
    log_info "配置参数："
    log_info "  网络接口: $iface"
    log_info "  IP地址: $ip/24"
    log_info "  网关: $gateway"
    log_info "  DNS: $dns1, $dns2"
    
    read -p "确认上述配置？(y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        configure_network "$iface" "$ip" "$gateway" "$dns1" "$dns2"
        return 0
    else
        log_warn "已取消配置"
        return 1
    fi
}

# 主函数
main() {
    log_info "==================== Debian/Ubuntu 初始化脚本 ===================="
    
    check_root
    check_system
    
    # 更新系统
    update_system
    
    # 安装基础工具
    install_tools
    
    # 配置网络
    if [[ $# -eq 0 ]]; then
        log_info "未提供网络参数，进入交互模式"
        interactive_setup
    else
        # 命令行参数模式: iface ip gateway [dns1] [dns2]
        if [[ $# -lt 3 ]]; then
            log_error "用法: $0 [iface] [ip] [gateway] [dns1] [dns2]"
            log_error "或直接运行进入交互模式: $0"
            exit 1
        fi
        
        configure_network "$1" "$2" "$3" "${4:-8.8.8.8}" "${5:-8.8.4.4}"
    fi
    
    # 启用Root SSH登录
    if [[ "$HAS_TTY" == "false" ]]; then
        log_warn "非交互模式，自动启用 root SSH 登录"
        enable_root_ssh
        generate_ssh_keys
    else
        read -p "启用 root SSH 登录？(y/n): " enable_ssh
        if [[ "$enable_ssh" =~ ^[Yy]$ ]]; then
            enable_root_ssh
            generate_ssh_keys
        fi
    fi
    
    # 显示系统信息
    echo ""
    log_info "==================== 初始化完成 ===================="
    log_info "系统信息:"
    log_info "  主机名: $(hostname)"
    log_info "  IP地址: $(hostname -I)"
    log_info "  SSH状态: $(systemctl is-active ssh || systemctl is-active sshd)"
    echo ""
}

# 执行主函数
main "$@"
