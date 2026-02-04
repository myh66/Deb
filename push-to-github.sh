#!/bin/bash

##############################################################################
# GitHub 推送自动化脚本
# 使用方式: bash push-to-github.sh
##############################################################################

set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  GitHub 推送自动化脚本                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 检查Git配置
echo -e "${YELLOW}[1/5]${NC} 检查Git配置..."
if ! git config user.name &>/dev/null; then
    echo -e "${RED}✗ 未配置Git用户名${NC}"
    read -p "请输入Git用户名: " git_user
    git config --global user.name "$git_user"
fi
echo -e "${GREEN}✓ Git用户名: $(git config user.name)${NC}"

if ! git config user.email &>/dev/null; then
    echo -e "${RED}✗ 未配置Git邮箱${NC}"
    read -p "请输入Git邮箱: " git_email
    git config --global user.email "$git_email"
fi
echo -e "${GREEN}✓ Git邮箱: $(git config user.email)${NC}"
echo ""

# 获取GitHub用户名
echo -e "${YELLOW}[2/5]${NC} 获取GitHub信息..."
read -p "请输入您的GitHub用户名: " github_user
if [[ -z "$github_user" ]]; then
    echo -e "${RED}✗ GitHub用户名不能为空${NC}"
    exit 1
fi
echo -e "${GREEN}✓ GitHub用户名: $github_user${NC}"
echo ""

# 选择认证方式
echo -e "${YELLOW}[3/5]${NC} 选择认证方式..."
echo "  1. SSH (推荐)"
echo "  2. HTTPS"
read -p "请选择 [1-2] (默认1): " auth_method
auth_method=${auth_method:-1}

case $auth_method in
    1)
        auth_type="ssh"
        repo_url="git@github.com:${github_user}/Deb.git"
        echo -e "${GREEN}✓ 选择SSH认证${NC}"
        ;;
    2)
        auth_type="https"
        repo_url="https://github.com/${github_user}/Deb.git"
        echo -e "${GREEN}✓ 选择HTTPS认证${NC}"
        ;;
    *)
        echo -e "${RED}✗ 无效选择${NC}"
        exit 1
        ;;
esac
echo ""

# 配置远程仓库
echo -e "${YELLOW}[4/5]${NC} 配置远程仓库..."
echo -e "${BLUE}仓库URL: $repo_url${NC}"

# 检查是否已存在远程仓库
if git remote | grep -q origin; then
    echo -e "${YELLOW}⚠ 远程仓库origin已存在${NC}"
    read -p "是否要重新配置? (y/n): " reconfig
    if [[ "$reconfig" =~ ^[Yy]$ ]]; then
        git remote remove origin
        echo -e "${GREEN}✓ 已删除旧的远程仓库${NC}"
    else
        echo -e "${YELLOW}使用现有远程仓库配置${NC}"
    fi
fi

if ! git remote | grep -q origin; then
    git remote add origin "$repo_url"
    echo -e "${GREEN}✓ 远程仓库已配置${NC}"
else
    echo -e "${GREEN}✓ 远程仓库已存在${NC}"
fi
echo ""

# 推送到GitHub
echo -e "${YELLOW}[5/5]${NC} 推送到GitHub..."
echo -e "${BLUE}即将执行以下命令:${NC}"
echo "  git branch -M main"
echo "  git push -u origin main"
echo ""

read -p "确认推送? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}已取消推送${NC}"
    exit 0
fi

# 执行推送
echo ""
git branch -M main
echo -e "${GREEN}✓ 分支已设置为main${NC}"

if git push -u origin main 2>&1; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      🎉 推送成功！                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "仓库地址: ${BLUE}https://github.com/${github_user}/Deb${NC}"
    echo ""
    echo -e "${YELLOW}后续步骤:${NC}"
    echo "  1. 访问上述URL查看仓库"
    echo "  2. (可选) 添加README到仓库主页"
    echo "  3. (可选) 配置仓库Settings (Stars, Forks等)"
    echo ""
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║      推送失败                          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$auth_type" == "ssh" ]]; then
        echo -e "${YELLOW}可能是SSH认证问题，请尝试:${NC}"
        echo "  1. 检查SSH密钥: ssh -T git@github.com"
        echo "  2. 添加SSH密钥: ssh-add ~/.ssh/id_rsa"
        echo "  3. 或使用HTTPS: 运行此脚本并选择选项2"
    else
        echo -e "${YELLOW}可能是HTTPS认证问题，请尝试:${NC}"
        echo "  1. 确认密码或Token正确"
        echo "  2. 生成Personal Access Token: https://github.com/settings/tokens"
        echo "  3. 使用Token代替密码重试"
    fi
    
    exit 1
fi
