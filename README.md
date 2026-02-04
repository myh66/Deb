# Debian/Ubuntu 初始化脚本

一个完整的 Bash 初始化脚本，用于配置 Debian/Ubuntu 系统的静态网络和启用 root SSH 登录。

[![GitHub](https://img.shields.io/badge/GitHub-myh66/Deb-blue?logo=github)](https://github.com/myh66/Deb)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📚 文档导航

- [快速开始指南](QUICKSTART.md) - 30秒快速配置
- [配置示例](EXAMPLES.md) - 8种常见场景配置
- [部署指南](DEPLOY.md) - 生产环境部署方法

## 功能特性

✅ 支持 **netplan** 和 **ifupdown** 两种网络配置方式
✅ 静态IP地址配置
✅ 自定义DNS设置
✅ 启用 root SSH 登录
✅ 生成 SSH 密钥对
✅ 系统包更新和基础工具安装
✅ 交互式和命令行两种使用方式
✅ 彩色日志输出和错误处理

## 快速开始

### 方式1：远程下载并执行（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh | sudo bash
```

或使用 GitHub 加速镜像：

```bash
curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh | sudo bash
```

### 方式2：交互式模式（需要手动输入参数）

```bash
sudo bash init-debian.sh
```

脚本会提示你输入：
- 网络接口名称（如 eth0）
- 静态IP地址（如 192.168.1.10）
- 网关地址（如 192.168.1.1）
- DNS服务器（可选，默认8.8.8.8和8.8.4.4）

### 方式3：命令行参数模式（无需交互）

```bash
sudo bash init-debian.sh eth0 192.168.1.10 192.168.1.1 8.8.8.8 8.8.4.4
```

**参数说明：**
- `eth0` - 网络接口名称
- `192.168.1.10` - 静态IP地址（/24子网）
- `192.168.1.1` - 网关地址
- `8.8.8.8` - DNS1（可选，默认8.8.8.8）
- `8.8.4.4` - DNS2（可选，默认8.8.4.4）

## 脚本执行流程

1. **权限检查** - 验证以 root 身份运行
2. **系统检查** - 确认为 Debian/Ubuntu 系统
3. **包管理** - 更新软件包列表
4. **工具安装** - 安装基础工具（curl, wget, vim, git, net-tools）
5. **网络配置** - 根据系统自动选择 netplan 或 ifupdown
6. **SSH配置** - 启用 root SSH 登录
7. **密钥生成** - 为 root 用户生成 SSH 密钥对

## 网络配置自动检测

**Netplan** (现代系统如 Ubuntu 18.04+)
```
/etc/netplan/00-static-ip.yaml
```

**ifupdown** (传统系统如 Debian 10)
```
/etc/network/interfaces.d/99-static-ip
```

## SSH 配置细节

脚本会修改 `/etc/ssh/sshd_config`，设置：
```
PermitRootLogin yes
```

原始配置会被备份为 `/etc/ssh/sshd_config.bak`

## GitHub 仓库

项目地址：[https://github.com/myh66/Deb](https://github.com/myh66/Deb)

### 克隆仓库
```bash
git clone https://github.com/myh66/Deb.git
cd Deb
sudo bash init-debian.sh
```

### 下载单个脚本
```bash
wget https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh
chmod +x init-debian.sh
sudo ./init-debian.sh
```

## 安全建议

⚠️ **在生产环境使用时，请注意以下事项：**

1. **验证脚本完整性**
   ```bash
   # 下载脚本并查看内容
   curl -fsSL https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh | cat
   # 验证后再执行
   curl -fsSL https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh | sudo bash
   ```

2. **使用HTTPS传输**
   ```bash
   # GitHub 提供 HTTPS 传输
   curl -fsSL https://raw.githubusercontent.com/myh66/Deb/main/init-debian.sh | sudo bash
   ```

3. **仅在可信网络环境执行**

4. **使用测试工具验证**
   ```bash
   # 克隆仓库后使用验证工具
   bash verify.sh
   bash test-syntax.sh
   ```

5. **配置SSH认证**
   - 建议使用公钥认证（禁用密码认证）
   - 修改SSH默认端口（生产环境）
   - 配置防火墙规则限制SSH访问IP

6. **备份原始配置**
   - 脚本自动备份 sshd_config
   - 网络配置修改前建议手动备份

## 故障排除

### SSH 连接失败
```bash
# 检查 SSH 服务状态
sudo systemctl status ssh

# 验证 sshd 配置
sudo sshd -t

# 查看SSH日志
sudo journalctl -u ssh -f
```

### 网络配置无法生效
```bash
# Netplan调试
sudo netplan --debug apply

# ifupdown调试
sudo ifup -v eth0
```

### 恢复原始SSH配置
```bash
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## 日志输出示例

```
[INFO] 检测到Debian/Ubuntu系统
[INFO] 更新系统包列表
[INFO] 安装基础工具
[INFO] 使用 netplan 配置网络接口: eth0
[INFO] netplan 配置已应用
[INFO] 配置 SSH 以允许 root 登录
[INFO] SSH 服务已重启，root 登录已启用
[INFO] 为 root 用户生成 SSH 密钥
[INFO] SSH 密钥已生成: /root/.ssh/id_rsa
[INFO] ==================== 初始化完成 ====================
```

## 系统兼容性

| 系统 | 版本 | 网络工具 | 状态 |
|------|------|---------|------|
| Debian | 10+ | ifupdown | ✅ |
| Debian | 11+ | netplan | ✅ |
| Ubuntu | 18.04+ | netplan | ✅ |
| Ubuntu | 20.04+ | netplan | ✅ |

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request！
