# Debian/Ubuntu 初始化脚本

一个智能交互式 Bash 初始化脚本，用于配置 Debian/Ubuntu 系统的网络（支持静态IP）和启用 root SSH 登录。

[![GitHub](https://img.shields.io/badge/GitHub-myh66/Deb-blue?logo=github)](https://github.com/myh66/Deb)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📚 文档导航

- [快速开始指南](QUICKSTART.md) - 30秒快速配置
- [配置示例](EXAMPLES.md) - 8种常见场景配置
- [部署指南](DEPLOY.md) - 生产环境部署方法

## ✨ 功能特性

### 网络配置
✅ **智能网卡检测** - 自动推荐UP状态的网络接口  
✅ **当前IP检测** - 自动识别当前IP/网关/DNS配置  
✅ **静态IP可选** - 保留当前IP或配置为静态  
✅ **双引擎支持** - 自动适配 **netplan** 和 **ifupdown**  
✅ **防断线保护** - 应用前警告，可选延迟到重启生效  
✅ **现代语法** - 使用netplan routes（替代已弃用的gateway4）  
✅ **安全权限** - 配置文件600权限保护  

### SSH配置
✅ **root密码登录** - 启用SSH root登录（默认操作）  
✅ **SSH密钥可选** - 可选生成RSA 4096位密钥对  
✅ **配置备份** - 自动备份原始sshd_config  

### 系统增强
✅ **用户状态检测** - 识别sudo/root执行方式  
✅ **智能重启提示** - 网络配置后建议重启  
✅ **彩色日志输出** - 清晰的执行反馈  
✅ **基础工具安装** - curl, wget, vim, git, net-tools等  

## 🚀 快速开始

### 方式1：远程执行（推荐）

```bash
curl -fsSL "https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh?t=$(date +%s)" | sudo bash
```

### 方式2：Git克隆（最可靠，避免GitHub CDN缓存）

```bash
git clone https://github.com/myh66/Deb.git
cd Deb
sudo bash init-debian.sh
```

### 方式3：下载后执行

```bash
wget https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh
chmod +x init-debian.sh
sudo ./init-debian.sh
```

## 📋 交互式配置流程

脚本采用**纯交互式设计**，引导您完成配置：

### 1. 网络接口选择
```
[INFO] 系统网络接口：
  ✓ ens18 (状态: UP)
  ○ ens19 (状态: DOWN)

[INFO] 推荐使用网卡: ens18
请输入要配置的网络接口（直接回车使用推荐: ens18）: 
```
**默认**: 回车使用推荐的UP状态网卡

### 2. IP地址配置
```
[INFO] 检测到当前网络配置:
[INFO]   IP地址: 192.168.2.5
[INFO]   网关: 192.168.2.1
[INFO]   DNS: 8.8.8.8, 8.8.4.4

是否使用此 IP？(y/n 直接回车使用 y): 
```
**默认**: y（使用当前IP）

**选择 y**：
```
是否将其修改为静态？(y/n 直接回车使用 n): 
```
- **n (默认)**: 保持现状，不配置静态IP
- **y**: 将当前IP配置为静态

**选择 n**：跳过网络配置，进入下一步

如果选择配置静态IP，会有应用前警告：
```
[警告] 应用网络配置会立即生效，可能导致SSH连接短暂中断！

建议操作方式：
  1) 立即应用（可能断线，需手动重连）
  2) 仅保存配置，稍后手动重启系统

请选择 (1/2 直接回车使用 2): 
```
**默认**: 2（保存配置，重启时生效，不断线）

### 3. SSH配置
```
[INFO] root SSH 登录配置：
[INFO]   • 启用 root SSH 密码登录（允许使用密码远程登录 root 账户）

是否启用 root SSH 密码登录？(y/n 直接回车使用 y): 
```
**默认**: y（启用root密码登录）

```
[INFO] SSH 密钥配置（可选）：
[INFO]   • SSH 密钥用于免密登录，比密码更安全
[INFO]   • 如果您不需要免密登录，可以跳过

是否生成 SSH 密钥对？(y/n 直接回车跳过): 
```
**默认**: n（跳过密钥生成）

### 4. 系统重启
```
[INFO] ========== 系统重启 ==========
[INFO] 建议：
[INFO]   • 网络配置更改后建议重启以确保生效
[INFO]   • SSH 配置已生效，无需重启

是否现在重启系统？(y/n 直接回车跳过): 
```
**默认**: n（跳过重启）

## 🔧 配置文件位置

### Netplan配置 (Ubuntu 18.04+, Debian 11+)
```bash
/etc/netplan/00-static-ip.yaml
```

配置格式（现代语法）：
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens18:
      dhcp4: false
      addresses:
        - 192.168.2.5/24
      routes:
        - to: default
          via: 192.168.2.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

### ifupdown配置 (Debian 10)
```bash
/etc/network/interfaces.d/99-static-ip
```

### SSH配置
```bash
/etc/ssh/sshd_config       # 修改后的配置
/etc/ssh/sshd_config.bak   # 自动备份
```

## ⚙️ 技术细节

### 网络配置引擎

脚本自动检测系统使用的网络管理工具：

| 系统 | 默认工具 | 检测方式 |
|------|---------|---------|
| Ubuntu 18.04+ | netplan | 检测 `/etc/netplan/` 目录 |
| Debian 11+ | netplan | 检测 `netplan` 命令 |
| Debian 10 | ifupdown | 检测 `/etc/network/interfaces` |

### 智能功能

**网卡推荐算法**:
1. 优先推荐 UP 状态的网卡
2. 如果多个UP，选择第一个
3. 如果没有UP，选择第一个可用网卡

**当前IP检测**:
- 从 `ip addr show` 提取IP地址
- 从 `ip route show` 提取默认网关
- 从 `/etc/resolv.conf` 提取DNS服务器

**防断线机制**:
- 应用网络配置前显示黄色警告
- 提供两个选项：立即应用（可能断线）或延迟到重启
- 默认选项2（安全模式），保存配置但不立即应用

### 权限和安全

- Netplan配置文件：`600` (仅root可读写)
- ifupdown配置文件：`644` (标准权限)
- SSH密钥：`600` (私钥) / `644` (公钥)
- 自动备份 sshd_config 为 `.bak`

## 🔍 验证静态IP配置

### 查看当前IP配置
```bash
# 查看IP地址（检查是否为 static 而非 dynamic）
ip addr show ens18

# 查看路由
ip route show

# 查看DNS
cat /etc/resolv.conf
```

### 查看配置文件
```bash
# Netplan系统
cat /etc/netplan/00-static-ip.yaml
sudo netplan --debug apply

# ifupdown系统
cat /etc/network/interfaces.d/99-static-ip
```

### 连接性测试
```bash
# 测试网关连通性
ping -c 4 192.168.2.1

# 测试DNS解析
ping -c 4 www.baidu.com

# 测试外网连接
curl -I https://www.google.com
```

## 🛡️ 安全建议

⚠️ **在生产环境使用时，请注意以下事项：**

### 1. 验证脚本完整性
```bash
# 下载脚本并查看内容
curl -fsSL https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh | cat
# 或使用git克隆查看
git clone https://github.com/myh66/Deb.git
cd Deb
cat init-debian.sh
```

### 2. 使用测试工具
```bash
# 语法检查
bash test-syntax.sh

# 功能验证
bash verify.sh
```

### 3. SSH安全加固（建议）
```bash
# 修改SSH端口（生产环境推荐）
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# 禁用密码认证，仅使用密钥（更安全）
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh

# 配置防火墙
sudo ufw allow 2222/tcp
sudo ufw enable
```

### 4. 网络配置备份
```bash
# 备份netplan配置
sudo cp -r /etc/netplan /etc/netplan.backup

# 备份ifupdown配置
sudo cp /etc/network/interfaces /etc/network/interfaces.backup
```

### 5. 仅在可信网络执行

远程执行脚本虽然方便，但建议：
- 首次使用先clone到本地查看代码
- 在测试环境验证后再用于生产
- 避免在不安全的网络环境执行

## 🐛 故障排除

### SSH 连接失败
```bash
# 检查 SSH 服务状态
sudo systemctl status ssh

# 验证 sshd 配置语法
sudo sshd -t

# 查看SSH日志
sudo journalctl -u ssh -n 50

# 恢复原始配置
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### 网络配置未生效
```bash
# Netplan调试
sudo netplan --debug apply

# 检查systemd-networkd状态
sudo systemctl status systemd-networkd

# 手动启用服务
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd

# ifupdown调试
sudo ifdown ens18 && sudo ifup ens18 -v
```

### 静态IP显示为dynamic
这是正常的，说明您在配置时选择了「保留当前IP」但未选择「修改为静态」。  
如需配置静态IP，重新运行脚本并在询问时选择 `y`。

### GitHub CDN缓存问题
如果curl获取的是旧版本：
```bash
# 方法1: 添加时间戳参数（通常有效）
curl -fsSL "https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh?t=$(date +%s)" | sudo bash

# 方法2: 使用git clone（最可靠）
git clone https://github.com/myh66/Deb.git && cd Deb && sudo bash init-debian.sh

# 方法3: 等待5-10分钟后重试
```

```

## 📊 日志输出示例

```
[INFO] ==================== Debian/Ubuntu 初始化脚本 ====================
[INFO] 检测到Debian/Ubuntu系统
[INFO] 更新系统包列表
[INFO] 安装基础工具
[INFO] 基础工具安装完成

[INFO] 系统网络接口：
  ✓ ens18 (状态: UP)

[INFO] 推荐使用网卡: ens18
请输入要配置的网络接口（直接回车使用推荐: ens18）: 

[INFO] 检测到当前网络配置:
[INFO]   IP地址: 192.168.2.5
[INFO]   网关: 192.168.2.1
[INFO]   DNS: 8.8.8.8, 8.8.4.4

是否使用此 IP？(y/n 直接回车使用 y): 
[INFO] 使用当前 IP 地址
是否将其修改为静态？(y/n 直接回车使用 n): y
[INFO] ========== 确认配置 ==========
[INFO]   网络接口: ens18
[INFO]   IP地址: 192.168.2.5/24
[INFO]   网关: 192.168.2.1
[INFO]   DNS: 8.8.8.8, 8.8.4.4

确认上述配置？(y/n 直接回车使用 y): 
[INFO] 使用 netplan 配置网络接口: ens18

[警告] 应用网络配置会立即生效，可能导致SSH连接短暂中断！

建议操作方式：
  1) 立即应用（可能断线，需手动重连）
  2) 仅保存配置，稍后手动重启系统

请选择 (1/2 直接回车使用 2): 
[INFO] 配置已保存到 /etc/netplan/00-static-ip.yaml
[INFO] 将在系统重启时自动生效，或稍后手动执行: netplan apply

[INFO] ========== SSH 配置 ==========
[INFO] 配置 SSH 以允许 root 登录
[INFO] 已备份原始 sshd_config
[INFO] SSH 服务已重启，root 登录已启用
[INFO] ✓ 已启用 root SSH 密码登录

[INFO] 已跳过密钥生成，可稍后手动执行: ssh-keygen -t rsa

[INFO] ==================== 初始化完成 ====================
[INFO] 系统信息:
[INFO]   主机名: debian
[INFO]   IP地址: 192.168.2.5
[INFO]   SSH状态: active

[INFO] 当前用户状态:
[INFO]   • 您通过 sudo 以普通用户 user 的身份执行脚本
[INFO]   • root 用户已配置，可以使用 su root 或 sudo -i 切换

[INFO] ========== 系统重启 ==========
[INFO] 建议：
[INFO]   • 网络配置更改后建议重启以确保生效
[INFO]   • SSH 配置已生效，无需重启

是否现在重启系统？(y/n 直接回车跳过): n
[INFO] 已跳过重启，可稍后手动执行: sudo reboot
```

## 📈 系统兼容性

| 系统 | 版本 | 网络工具 | Netplan语法 | 状态 |
|------|------|---------|------------|------|
| Debian | 10 (Buster) | ifupdown | - | ✅ 测试通过 |
| Debian | 11 (Bullseye) | netplan | routes | ✅ 测试通过 |
| Debian | 12+ (Bookworm) | netplan | routes | ✅ 测试通过 |
| Ubuntu | 18.04 LTS | netplan | routes | ✅ 支持 |
| Ubuntu | 20.04 LTS | netplan | routes | ✅ 支持 |
| Ubuntu | 22.04 LTS | netplan | routes | ✅ 支持 |
| Ubuntu | 24.04 LTS | netplan | routes | ✅ 支持 |

> **注意**: 脚本使用现代netplan语法（`routes`），已弃用的 `gateway4` 不再使用。

## 📝 更新日志

### v2.0 (2026-02-05)
- ✨ 重构为纯交互式设计，移除命令行参数模式
- ✨ 添加智能网卡检测（优先推荐UP状态网卡）
- ✨ 添加当前IP/网关/DNS自动检测
- ✨ 添加静态IP可选配置（保留现状或配置静态）
- ✨ 分离SSH配置：root密码登录（默认）+ 密钥生成（可选）
- ✨ 添加用户状态检测（sudo vs root）
- ✨ 添加重启询问功能
- 🐛 修复netplan配置：使用routes替代gateway4（弃用警告）
- 🐛 修复文件权限：netplan配置改为600权限
- 🐛 修复服务启动：自动启用systemd-networkd
- 🛡️ 添加网络配置应用前警告（防止SSH断线）
- 🛡️ 提供延迟应用选项（保存配置，重启时生效）

### v1.0 (2026-01-28)
- 🎉 初始版本发布
- ✅ 支持netplan和ifupdown
- ✅ 基础静态IP配置
- ✅ SSH root登录配置

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发测试
```bash
# 克隆仓库
git clone https://github.com/myh66/Deb.git
cd Deb

# 语法检查
bash test-syntax.sh

# 功能验证
bash verify.sh

# 提交更改
git add .
git commit -m "描述你的更改"
git push origin main
```

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 📧 联系方式

- GitHub Issues: [https://github.com/myh66/Deb/issues](https://github.com/myh66/Deb/issues)
- GitHub: [@myh66](https://github.com/myh66)

---

⭐ 如果这个项目对您有帮助，请给个 Star！
