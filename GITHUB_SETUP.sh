#!/bin/bash

##############################################################################
# 推送到GitHub的说明和命令
# 用户需要按照以下步骤将本地仓库推送到GitHub
##############################################################################

echo "╔════════════════════════════════════════════════════╗"
echo "║   将项目推送到GitHub (步骤说明)                   ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

echo "📋 前置要求：
  ✓ GitHub账号已创建
  ✓ Git已安装和配置（user.name, user.email）
  ✓ SSH密钥或HTTPS认证已配置"
echo ""

echo "╔════════════════════════════════════════════════════╗"
echo "║ 步骤1: 在GitHub创建仓库                           ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "  1. 登录 https://github.com"
echo "  2. 点击 '+' 图标 → 'New repository'"
echo "  3. Repository name: 输入 'Deb'"
echo "  4. Description: Debian/Ubuntu initialization script"
echo "  5. Visibility: 选择 'Public'"
echo "  6. 其他选项保持默认"
echo "  7. 点击 'Create repository'"
echo ""

echo "╔════════════════════════════════════════════════════╗"
echo "║ 步骤2: 将本地仓库连接到GitHub                    ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "请将以下命令中的 'YOUR_USERNAME' 替换为您的GitHub用户名："
echo ""
echo "方式A：使用SSH（推荐，前提是已配置SSH密钥）"
echo "  git remote add origin git@github.com:YOUR_USERNAME/Deb.git"
echo "  git branch -M main"
echo "  git push -u origin main"
echo ""
echo "方式B：使用HTTPS（如果未配置SSH密钥）"
echo "  git remote add origin https://github.com/YOUR_USERNAME/Deb.git"
echo "  git branch -M main"
echo "  git push -u origin main"
echo ""
echo "  然后输入您的GitHub用户名和Personal Access Token（或密码）"
echo ""

echo "╔════════════════════════════════════════════════════╗"
echo "║ 步骤3: 验证推送成功                              ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "  1. 访问 https://github.com/YOUR_USERNAME/Deb"
echo "  2. 确认所有文件已上传"
echo "  3. 检查commit历史记录"
echo ""

echo "╔════════════════════════════════════════════════════╗"
echo "║ 本地仓库当前状态                                  ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

cd /Users/x1aoma/Project/code

echo "当前分支："
git branch
echo ""

echo "提交历史："
git log --oneline -5
echo ""

echo "远程仓库设置："
git remote -v
if [[ -z $(git remote -v) ]]; then
    echo "  （尚未配置远程仓库）"
fi
echo ""

echo "╔════════════════════════════════════════════════════╗"
echo "║ 自动化脚本（可选）                                ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "如果您已经有SSH密钥，可以运行以下脚本自动推送："
echo ""
echo "  #!/bin/bash"
echo "  read -p '请输入您的GitHub用户名: ' USERNAME"
echo "  git remote add origin git@github.com:\$USERNAME/Deb.git"
echo "  git branch -M main"
echo "  git push -u origin main"
echo ""

echo "╔════════════════════════════════════════════════════╗"
echo "║ 故障排除                                          ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

echo "❌ 问题1: 'Permission denied (publickey)' SSH错误"
echo "  解决: 
    - 检查SSH密钥: ssh-key-add ~/.ssh/id_rsa
    - 或使用HTTPS方式
    - 或生成新SSH密钥: ssh-keygen -t rsa -b 4096"
echo ""

echo "❌ 问题2: '远程仓库已存在' 错误"
echo "  解决: 运行 git remote remove origin 后重试"
echo ""

echo "❌ 问题3: 'Authentication failed' HTTPS错误"
echo "  解决:
    - 使用 Personal Access Token 代替密码
    - 访问: https://github.com/settings/tokens"
echo ""

echo "✅ 完成！"
echo ""
echo "如需帮助，请查看官方文档:"
echo "  - GitHub创建仓库: https://docs.github.com/en/get-started/quickstart/create-a-repo"
echo "  - Git推送指南: https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository"
