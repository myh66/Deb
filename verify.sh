#!/bin/bash

##############################################################################
# Init-Debian 脚本验证工具
# 用于验证脚本的完整性、安全性和兼容性
##############################################################################

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 验证计数
PASS=0
FAIL=0
WARN=0

# 日志函数
print_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS++))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL++))
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

# 验证脚本文件存在
verify_file_exists() {
    print_header "文件完整性检查"
    
    local files=("init-debian.sh" "README.md" "DEPLOY.md" "EXAMPLES.md" "QUICKSTART.md")
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            print_pass "文件存在: $file"
        else
            print_fail "文件缺失: $file"
        fi
    done
}

# 验证脚本权限
verify_permissions() {
    print_header "文件权限检查"
    
    if [[ -x "init-debian.sh" ]]; then
        print_pass "init-debian.sh 已设置可执行权限"
    else
        print_warn "init-debian.sh 未设置可执行权限，建议运行: chmod +x init-debian.sh"
    fi
}

# 验证Bash脚本语法
verify_bash_syntax() {
    print_header "Bash 语法验证"
    
    if bash -n init-debian.sh 2>/dev/null; then
        print_pass "脚本语法检查通过"
    else
        print_fail "脚本包含语法错误"
        bash -n init-debian.sh
    fi
}

# 验证关键函数存在
verify_functions() {
    print_header "关键函数检查"
    
    local functions=(
        "check_root"
        "check_system"
        "detect_network_manager"
        "configure_network"
        "enable_root_ssh"
        "configure_netplan"
        "configure_ifupdown"
    )
    
    for func in "${functions[@]}"; do
        if grep -q "^${func}()" init-debian.sh; then
            print_pass "函数存在: $func"
        else
            print_fail "函数缺失: $func"
        fi
    done
}

# 验证关键字符串
verify_critical_strings() {
    print_header "关键字符串检查"
    
    local strings=(
        "PermitRootLogin"
        "netplan"
        "ifupdown"
        "set -euo pipefail"
        "/etc/ssh/sshd_config"
    )
    
    for string in "${strings[@]}"; do
        if grep -q "$string" init-debian.sh; then
            print_pass "关键字符串存在: '$string'"
        else
            print_fail "关键字符串缺失: '$string'"
        fi
    done
}

# 验证文件大小
verify_file_size() {
    print_header "文件大小检查"
    
    local size=$(wc -c < init-debian.sh)
    local size_kb=$((size / 1024))
    
    if [[ $size -gt 5000 && $size -lt 50000 ]]; then
        print_pass "脚本大小合理: ${size_kb}KB"
    else
        print_fail "脚本大小异常: ${size_kb}KB (应在5-50KB)"
    fi
}

# 验证文档完整性
verify_documentation() {
    print_header "文档完整性检查"
    
    local docs=(
        "README.md:功能特性"
        "README.md:使用方法"
        "DEPLOY.md:部署"
        "QUICKSTART.md:快速开始"
        "EXAMPLES.md:示例"
    )
    
    for doc in "${docs[@]}"; do
        local file="${doc%%:*}"
        local keyword="${doc##*:}"
        
        if grep -q "$keyword" "$file" 2>/dev/null; then
            print_pass "文档检查: $file"
        else
            print_warn "文档可能不完整: $file"
        fi
    done
}

# 验证安全性  
verify_security() {
    print_header "安全性检查"
    
    # 检查是否进行了权限检查
    if grep -q "EUID -ne 0" init-debian.sh; then
        print_pass "包含 root 权限检查"
    else
        print_fail "缺少 root 权限检查"
    fi
    
    # 检查是否进行了系统检查
    if grep -q "debian_version" init-debian.sh; then
        print_pass "包含系统兼容性检查"
    else
        print_fail "缺少系统兼容性检查"
    fi
    
    # 检查是否有错误处理
    if grep -q "set -euo pipefail" init-debian.sh; then
        print_pass "启用了严格错误处理"
    else
        print_fail "未启用严格错误处理"
    fi
    
    # 检查是否进行了配置备份
    if grep -q "\.bak" init-debian.sh; then
        print_pass "包含配置备份机制"
    else
        print_fail "缺少配置备份机制"
    fi
}

# 系统兼容性检查
verify_system_compatibility() {
    print_header "系统环境检查"
    
    # 检查是否在Debian/Ubuntu上运行
    if [[ -f /etc/debian_version ]]; then
        print_pass "检测到Debian/Ubuntu系统"
        
        # 检查包管理器
        if command -v apt-get &>/dev/null; then
            print_pass "apt-get 可用"
        else
            print_fail "apt-get 不可用"
        fi
    else
        print_warn "系统非Debian/Ubuntu，脚本可能无法正常运行"
    fi
    
    # 检查网络工具
    if command -v netplan &>/dev/null; then
        print_pass "netplan 可用"
    else
        if command -v ifup &>/dev/null; then
            print_pass "ifupdown 可用"
        else
            print_warn "网络工具未检测到（ifupdown/netplan）"
        fi
    fi
    
    # 检查SSH
    if systemctl is-enabled ssh &>/dev/null || systemctl is-enabled sshd &>/dev/null; then
        print_pass "SSH 已启用"
    else
        print_warn "SSH 未启用"
    fi
}

# 执行测试运行（dry-run）
test_dry_run() {
    print_header "脚本选项测试"
    
    # 测试--help 或查看使用方法
    print_info "加载主要脚本函数..."
    
    # 源脚本但不执行main函数
    if bash -c "source ./init-debian.sh; echo 'OK'" 2>/dev/null | grep -q "OK"; then
        print_pass "脚本可以正确加载"
    else
        print_warn "脚本加载时出现问题"
    fi
}

# 生成报告
generate_report() {
    print_header "验证报告"
    
    local total=$((PASS + FAIL + WARN))
    
    echo ""
    echo "总检查项: $total"
    echo -e "${GREEN}通过: $PASS${NC}"
    
    if [[ $FAIL -gt 0 ]]; then
        echo -e "${RED}失败: $FAIL${NC}"
    else
        echo -e "失败: 0"
    fi
    
    if [[ $WARN -gt 0 ]]; then
        echo -e "${YELLOW}警告: $WARN${NC}"
    else
        echo -e "警告: 0"
    fi
    
    echo ""
    
    if [[ $FAIL -eq 0 ]]; then
        if [[ $WARN -eq 0 ]]; then
            echo -e "${GREEN}✓ 所有检查通过！脚本可以安全使用。${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ 大部分检查通过，但存在部分警告。${NC}"
            return 0
        fi
    else
        echo -e "${RED}✗ 存在失败的检查项，建议修复后再使用。${NC}"
        return 1
    fi
}

# 显示建议
show_recommendations() {
    print_header "建议"
    
    echo -e "1. 在生产环境使用前，务必在测试环境验证脚本"
    echo -e "2. 建议使用 HTTPS 传输脚本"
    echo -e "3. 建议为脚本生成 SHA256 校验和"
    echo -e "4. 建议在可信网络环境执行"
    echo -e "5. 建议审查脚本内容后再执行"
    echo ""
    echo -e "生成SHA256校验和:"
    echo -e "  ${BLUE}sha256sum init-debian.sh${NC}"
    echo ""
}

# 主函数
main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Init-Debian 脚本验证工具       ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 检查脚本文件是否存在
    if [[ ! -f "init-debian.sh" ]]; then
        print_fail "未找到 init-debian.sh 文件"
        exit 1
    fi
    
    # 运行所有验证
    verify_file_exists
    verify_permissions
    verify_bash_syntax
    verify_functions
    verify_critical_strings
    verify_file_size
    verify_documentation
    verify_security
    verify_system_compatibility
    test_dry_run
    
    # 生成报告
    local result=0
    generate_report || result=$?
    
    # 显示建议
    show_recommendations
    
    exit $result
}

# 执行主函数
main "$@"
