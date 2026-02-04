# Debian/Ubuntu 初始化脚本 - 配置示例

## 场景1：Netplan 静态IP配置示例

**目标配置：**
- 系统：Ubuntu 20.04/22.04
- 网络接口：eth0
- IP地址：192.168.1.100/24
- 网关：192.168.1.1
- DNS：114.114.114.114, 8.8.8.8

**执行命令：**
```bash
sudo bash init-debian.sh eth0 192.168.1.100 192.168.1.1 114.114.114.114 8.8.8.8
```

**生成的配置文件：**
```yaml
# /etc/netplan/00-static-ip.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [114.114.114.114, 8.8.8.8]
```

---

## 场景2：ifupdown 静态IP配置示例

**目标配置：**
- 系统：Debian 10/11
- 网络接口：ens3
- IP地址：10.0.0.50/24
- 网关：10.0.0.1
- DNS：8.8.8.8, 8.8.4.4

**执行命令：**
```bash
sudo bash init-debian.sh ens3 10.0.0.50 10.0.0.1 8.8.8.8 8.8.4.4
```

**生成的配置文件：**
```
# /etc/network/interfaces.d/99-static-ip
auto ens3
iface ens3 inet static
    address 10.0.0.50
    netmask 255.255.255.0
    gateway 10.0.0.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

---

## 场景3：远程部署 (生产环境)

**步骤1：准备Web服务器**
```bash
# 在Web服务器上
sudo cp init-debian.sh /var/www/html/
sudo chown www-data:www-data /var/www/html/init-debian.sh
```

**步骤2：在新服务器上执行**
```bash
# 在目标服务器上
curl -fsSL http://your-webserver.com/init-debian.sh | sudo bash
```

**交互式配置过程：**
```
[INFO] 检测到Debian/Ubuntu系统
[INFO] 更新系统包列表
请输入要配置的网络接口（如：eth0）: eth0
请输入静态IP（如：192.168.1.10）: 192.168.1.10
请输入网关（如：192.168.1.1）: 192.168.1.1
请输入DNS1（默认：8.8.8.8）: 114.114.114.114
请输入DNS2（默认：8.8.4.4）: 8.8.4.4
[INFO] 确认上述配置？(y/n): y
启用 root SSH 登录？(y/n): y
[INFO] SSH 服务已重启，root 登录已启用
```

---

## 场景4：多网卡环境

**场景描述：** 服务器有多个网络接口（eth0, eth1, eth2）

**命令行参数模式：**
```bash
# 配置eth0
sudo bash init-debian.sh eth0 192.168.1.10 192.168.1.1

# 配置eth1
sudo bash init-debian.sh eth1 192.168.2.10 192.168.2.1
```

**验证配置：**
```bash
# 查看所有网络接口
ip addr show

# 查看路由表
ip route show

# 测试网络连接
ping 192.168.1.1
ping 192.168.2.1
```

---

## 场景5：云平台部署（AWS/Azure/DigitalOcean）

**AWS EC2 用户数据脚本：**
```bash
#!/bin/bash
curl -fsSL http://my-bucket.s3.amazonaws.com/init-debian.sh | sudo bash
```

**将以上脚本保存为 `user-data.txt`，在启动EC2实例时选择：**
- 高级详情 → 用户数据 → 粘贴脚本

---

## 场景6：带有SHA256校验的部署

**步骤1：生成校验和**
```bash
sha256sum init-debian.sh > init-debian.sh.sha256
cat init-debian.sh.sha256
# 输出: abc123def456... init-debian.sh
```

**步骤2：部署时验证**
```bash
# 下载脚本和校验文件
curl -fsSL http://your-server/init-debian.sh -o init-debian.sh
curl -fsSL http://your-server/init-debian.sh.sha256 -o init-debian.sh.sha256

# 验证完整性
sha256sum -c init-debian.sh.sha256

# 如果校验通过再执行
sudo bash init-debian.sh
```

---

## 场景7：企业网络配置

**特殊需求：**
- 静态IP：192.168.1.20/24
- 网关：192.168.1.254
- 主DNS（内网）：10.0.0.1
- 备DNS：8.8.8.8
- MTU值：9000（巨帧）

**修改脚本方法：**

编辑脚本中的 `configure_netplan()` 函数，修改为：
```bash
configure_netplan() {
    local iface=$1
    local ip=$2
    local gateway=$3
    local dns1=${4:-8.8.8.8}
    local dns2=${5:-8.8.4.4}
    
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
      mtu: 9000
      dhcp4-overrides:
        use-dns: true
EOF
    ...
}
```

**执行：**
```bash
sudo bash init-debian.sh eth0 192.168.1.20 192.168.1.254 10.0.0.1 8.8.8.8
```

---

## 场景8：卸载和恢复

**如需撤销所有更改：**
```bash
# 恢复SSH配置
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
sudo systemctl restart ssh

# 删除网络配置（Netplan）
sudo rm /etc/netplan/00-static-ip.yaml
sudo netplan apply

# 删除网络配置（ifupdown）
sudo rm /etc/network/interfaces.d/99-static-ip
sudo systemctl restart networking

# 验证
ip addr show
ip route show
```

---

## 常见问题排查

### 问题1：脚本权限不足
```bash
# 确保以 sudoer 身份运行
curl ... | sudo bash
```

### 问题2：网络配置未生效
```bash
# 检查配置文件内容
sudo cat /etc/netplan/00-static-ip.yaml
# 或
sudo cat /etc/network/interfaces.d/99-static-ip

# 手动应用
sudo netplan apply
# 或
sudo systemctl restart networking
```

### 问题3：SSH连接被拒绝
```bash
# 检查SSH运行状态
sudo systemctl status ssh

# 验证sshd配置
sudo sshd -t

# 查看日志
sudo journalctl -u ssh -n 50 -f
```

### 问题4：DNS不工作
```bash
# 检查resolv.conf
cat /etc/resolv.conf

# 测试DNS
nslookup google.com
dig google.com @8.8.8.8
```

---

## 性能优化建议

1. **并发网络连接优化**
   - 在SSH配置中添加连接池设置
   - 调整TCP缓冲区大小

2. **MTU优化**
   - 标准环境：1500
   - 巨帧网络：9000

3. **DNS缓存**
   - 可选安装 `systemd-resolved` 或 `dnsmasq`

示例（可选）：
```bash
# 安装systemd-resolved
sudo apt-get install -y systemd-resolved

# 修改resolv.conf指向本地缓存
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
```
