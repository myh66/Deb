#!/bin/bash

##############################################################################
# 脚本测试和部署指南
# 用于验证和部署 init-debian.sh
##############################################################################

# 1. 语法检查
echo "检查脚本语法..."
bash -n init-debian.sh && echo "✓ 语法检查通过" || echo "✗ 语法检查失败"

# 2. 权限设置
echo "设置执行权限..."
chmod +x init-debian.sh
chmod +x test-syntax.sh

# 3. 查看脚本大小
echo "脚本信息:"
echo "  文件名: init-debian.sh"
echo "  文件大小: $(ls -lh init-debian.sh | awk '{print $5}')"
echo "  行数: $(wc -l < init-debian.sh)"

# 4. 显示用法示例
echo ""
echo "================= 使用示例 ================="
echo ""
echo "方式1：交互式模式"
echo "  sudo bash init-debian.sh"
echo ""
echo "方式2：命令行参数模式"
echo "  sudo bash init-debian.sh eth0 192.168.1.10 192.168.1.1"
echo ""
echo "方式3：远程执行"
echo "  curl -fsSL http://your-server/init-debian.sh | sudo bash"
echo ""

# 5. 显示脚本功能
echo "================= 脚本功能清单 ================="
echo "✓ 系统版本检测（Debian/Ubuntu）"
echo "✓ 网络配置工具自动检测（netplan/ifupdown）"
echo "✓ 静态IP地址配置"
echo "✓ DNS服务器设置"
echo "✓ Root SSH远程登录启用"
echo "✓ SSH密钥对生成"
echo "✓ 系统包更新"
echo "✓ 基础工具安装"
echo "✓ 交互式和非交互式两种模式"
echo "✓ 详细的日志输出和错误处理"
echo ""

# 6. 生成部署说明
cat > DEPLOY.md <<'EOF'
# 部署指南

## 本地测试

在虚拟机或测试服务器上测试：

```bash
# 交互式模式
sudo bash init-debian.sh

# 非交互模式
sudo bash init-debian.sh eth0 192.168.1.10 192.168.1.1 8.8.8.8 8.8.4.4
```

## Web服务器部署

1. 上传脚本到Web服务器：
```bash
scp init-debian.sh user@webserver:/var/www/html/
```

2. 设置正确的权限和所有权：
```bash
sudo chown www-data:www-data /var/www/html/init-debian.sh
sudo chmod 644 /var/www/html/init-debian.sh
```

3. 在目标服务器执行：
```bash
curl -fsSL http://webserver.com/init-debian.sh | sudo bash
```

## 生成SHA256校验和（可选但推荐）

```bash
sha256sum init-debian.sh > init-debian.sh.sha256
```

部署时验证：
```bash
curl -fsSL http://webserver.com/init-debian.sh | tee init-debian.sh | sha256sum
# 与已知的SHA256值进行对比
```

## 使用GPG签名（高级安全）

1. 签名脚本：
```bash
gpg --armor --detach-sign init-debian.sh
```

2. 部署验证签名：
```bash
curl -fsSL http://webserver.com/init-debian.sh -o init-debian.sh
curl -fsSL http://webserver.com/init-debian.sh.asc -o init-debian.sh.asc
gpg --verify init-debian.sh.asc init-debian.sh
# 如果验证通过再执行
sudo bash init-debian.sh
```

## 问题排查

### Q: 脚本无法获取网络接口？
A: 执行 `ip link show` 检查可用的网络接口，确保使用正确的接口名称。

### Q: netplan 报错？
A: 检查 YAML 语法（缩进很重要）：
```bash
sudo netplan --debug apply
```

### Q: SSH 无法连接？
A: 检查 sshd 配置和日志：
```bash
sudo sshd -t
sudo journalctl -u ssh -f
```

### Q: 网络配置未生效？
A: 手动重启网络服务：
```bash
# Netplan
sudo netplan apply

# ifupdown
sudo systemctl restart networking
```

## 恢复原始状态

如果需要撤销更改：

1. 恢复SSH配置：
```bash
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
sudo systemctl restart ssh
```

2. 删除网络配置：
```bash
# Netplan
sudo rm /etc/netplan/00-static-ip.yaml
sudo netplan apply

# ifupdown
sudo rm /etc/network/interfaces.d/99-static-ip
sudo systemctl restart networking
```

## 监控和验证

执行后检查配置是否正确：

```bash
# 检查IP配置
ip addr show

# 检查网关
ip route show

# 检查DNS
cat /etc/resolv.conf

# 检查SSH状态
sudo systemctl status ssh
sudo ss -tlnp | grep ssh

# 测试root SSH登录
ssh root@<ip-address>
```

EOF

echo "✓ 已生成部署指南: DEPLOY.md"
