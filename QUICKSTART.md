# 快速开始指南 (Quick Start)

## ⚡ 30秒快速配置

### 最简单的方式：交互式模式
```bash
sudo bash init-debian.sh
```
然后按照提示输入网络配置信息。

---

## 📋 常见场景快速命令

### 场景1: 配置Ubuntu / Debian为静态IP + 启用root SSH

```bash
# 非交互模式（3个参数必须）
sudo bash init-debian.sh eth0 192.168.1.100 192.168.1.1
```

**参数说明：**
```
sudo bash init-debian.sh <网络卡> <IP地址> <网关>
```

---

### 场景2: 远程部署（curl方式）

```bash
# 第一次下载并执行（最常用）
curl -fsSL https://example.com/init-debian.sh | sudo bash

# 或先下载再执行
curl -fsSL https://example.com/init-debian.sh -o init-debian.sh
sudo bash init-debian.sh
```

---

### 场景3: 完整配置（自定义DNS）

```bash
sudo bash init-debian.sh eth0 192.168.1.100 192.168.1.1 114.114.114.114 8.8.8.8
```

**参数说明：**
```
sudo bash init-debian.sh <网卡> <IP> <网关> <DNS1> <DNS2>
```

---

## 🔍 配置后验证

```bash
# 查看IP配置
ip addr show

# 查看网关
ip route show

# 查看DNS
cat /etc/resolv.conf

# 检查SSH状态
systemctl status ssh

# 测试SSH登录（替换IP）
ssh root@192.168.1.100
```

---

## 🎯 配置前准备

### 查看网络接口名称
```bash
ip link show
# 输出示例：
# 1: lo: <LOOPBACK,UP,LOWER_UP> ...
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
# 3: eth1: <BROADCAST,MULTICAST> ...

# 使用 eth0 或 eth1 等配置
```

---

## 📱 支持的系统

| 系统 | 版本 | 网络工具 |
|------|------|---------|
| Debian | 10, 11, 12 | 自动检测 ✓ |
| Ubuntu | 18.04, 20.04, 22.04 | 自动检测 ✓ |

脚本会**自动检测**系统并选择合适的网络配置方式（netplan 或 ifupdown）。

---

## ⚠️ 重要提示

1. **必须以root权限运行**
   ```bash
   sudo bash init-debian.sh
   ```

2. **备份原始配置**（脚本会自动备份）
   ```bash
   # SSH配置备份位置
   /etc/ssh/sshd_config.bak
   ```

3. **检查网络连通性**
   ```bash
   # 配置前测试网关
   ping 192.168.1.1
   ```

---

## 🚨 出问题了？

### SSH连接失败
```bash
# 检查SSH服务
sudo systemctl restart ssh

# 验证sshd配置
sudo sshd -t

# 查看日志
sudo journalctl -u ssh -f
```

### 网络不通
```bash
# 检查配置文件
sudo cat /etc/netplan/00-static-ip.yaml    # Ubuntu 18.04+
# 或
sudo cat /etc/network/interfaces.d/99-static-ip  # Debian

# 重新应用配置
sudo netplan apply        # Netplan系统
# 或
sudo systemctl restart networking  # ifupdown系统
```

### 恢复原始配置
```bash
# 恢复SSH
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
sudo systemctl restart ssh

# 删除网络配置
sudo rm /etc/netplan/00-static-ip.yaml
# 或
sudo rm /etc/network/interfaces.d/99-static-ip
sudo systemctl restart networking
```

---

## 📚 进阶用法

详细配置示例和部署指南，请查看：
- **[README.md](README.md)** - 完整功能说明
- **[EXAMPLES.md](EXAMPLES.md)** - 8个场景配置示例
- **[DEPLOY.md](DEPLOY.md)** - 部署和故障排除指南

---

## 🔐 安全建议

✅ **生产环境建议：**
1. 使用HTTPS传输脚本
2. 验证脚本SHA256校验和
3. 仅在可信网络环境执行
4. 审核脚本内容后再执行
5. 配置SSH密钥认证（禁用密码）
6. 更改SSH默认端口
7. 配置防火墙限制SSH访问

```bash
# 示例：添加防火墙规则（UFW）
sudo ufw allow from 192.168.1.0/24 to any port 22
sudo ufw enable
```

---

## 💡 性能提示

**网络调优（可选）：**
```bash
# 编辑脚本，在网络配置中添加：

# 增大MTU（巨帧）- 适用于高性能网络
mtu: 9000

# 启用TCP优化
# 修改 /etc/sysctl.conf 然后 sysctl -p
```

---

## 📞 技术支持

遇到问题？检查以下内容：

1. **系统兼容性** - 确保是Debian或Ubuntu
2. **网络环境** - 确保网关和DNS可达
3. **权限** - 确保以sudo或root身份运行
4. **日志** - 查看脚本输出和系统日志

```bash
# 查看详细错误日志
sudo journalctl -n 100 -f
```

---

## 📋 常见命令汇总

| 任务 | 命令 |
|------|------|
| 交互式配置 | `sudo bash init-debian.sh` |
| 非交互配置 | `sudo bash init-debian.sh eth0 192.168.1.10 192.168.1.1` |
| 远程执行 | `curl -fsSL https://... \| sudo bash` |
| 查看IP | `ip addr show` |
| 重启网络 | `sudo netplan apply` 或 `sudo systemctl restart networking` |
| 检查SSH | `systemctl status ssh` |
| SSH测试 | `ssh root@192.168.1.10` |
| 查看日志 | `sudo journalctl -u ssh -f` |
| 恢复配置 | `sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config` |

---

**祝您配置顺利！🎉**
