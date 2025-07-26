# GitHub SSH 连接配置指南

## 🔐 SSH 密钥生成和配置步骤

### 第一步：生成SSH密钥

在PowerShell中执行以下命令：

```powershell
# 生成新的SSH密钥对
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**注意**：
- 将 `your_email@example.com` 替换为您的GitHub邮箱
- 如果系统不支持ed25519，可以使用RSA：
  ```powershell
  ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
  ```

**密钥生成过程中的选项**：
1. **文件保存位置**：直接按回车（使用默认位置：`~/.ssh/id_ed25519`）
2. **密码短语**：可以设置密码（推荐）或直接回车跳过

### 第二步：启动SSH代理

```powershell
# 启动SSH代理
Start-Service ssh-agent

# 将SSH密钥添加到代理
ssh-add "$env:USERPROFILE\.ssh\id_ed25519"
```

如果使用RSA密钥，则：
```powershell
ssh-add "$env:USERPROFILE\.ssh\id_rsa"
```

### 第三步：复制公钥到剪贴板

```powershell
# 复制ed25519公钥到剪贴板
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Set-Clipboard

# 或者如果使用RSA
Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" | Set-Clipboard
```

也可以直接查看并手动复制：
```powershell
cat "$env:USERPROFILE\.ssh\id_ed25519.pub"
```

### 第四步：在GitHub中添加SSH密钥

1. 登录 [GitHub](https://github.com)
2. 点击右上角头像 → **Settings**
3. 在左侧菜单中选择 **SSH and GPG keys**
4. 点击 **New SSH key**
5. 填写信息：
   - **Title**: 给密钥起个名字（如：我的电脑）
   - **Key**: 粘贴刚才复制的公钥内容
6. 点击 **Add SSH key**

### 第五步：测试SSH连接

```powershell
# 测试SSH连接
ssh -T git@github.com
```

成功的话会显示：
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### 第六步：克隆您的仓库

```powershell
# 克隆仓库
git clone git@github.com:wyw121/SmartCare_Cloud.git

# 进入仓库目录
cd SmartCare_Cloud
```

## 🛠️ 常见问题解决

### 问题1：ssh-keygen 命令不存在
**解决方案**：安装OpenSSH
```powershell
# 启用Windows的OpenSSH功能
Add-WindowsCapability -Online -Name OpenSSH.Client

# 或者使用chocolatey安装
choco install openssh
```

### 问题2：Permission denied (publickey)
**可能原因**：
1. SSH密钥未正确添加到GitHub
2. SSH代理未运行
3. 密钥文件权限问题

**解决步骤**：
```powershell
# 检查SSH代理状态
Get-Service ssh-agent

# 重新添加密钥
ssh-add -l  # 查看已添加的密钥
ssh-add "$env:USERPROFILE\.ssh\id_ed25519"

# 测试详细连接信息
ssh -vT git@github.com
```

### 问题3：ssh-agent 服务未启动
```powershell
# 设置ssh-agent服务为自动启动
Set-Service -Name ssh-agent -StartupType Automatic

# 启动服务
Start-Service ssh-agent
```

### 问题4：已有HTTPS仓库要改为SSH
```powershell
# 查看当前远程仓库URL
git remote -v

# 修改为SSH URL
git remote set-url origin git@github.com:wyw121/SmartCare_Cloud.git

# 验证修改
git remote -v
```

## 🎯 高级配置

### SSH配置文件优化
创建 `~/.ssh/config` 文件：

```powershell
# 创建SSH配置文件
New-Item -ItemType File -Path "$env:USERPROFILE\.ssh\config" -Force
```

配置内容：
```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

### 多个GitHub账户配置
如果您有多个GitHub账户：

```
# 个人账户
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    
# 工作账户
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
```

使用时：
```powershell
# 个人仓库
git clone git@github.com:username/repo.git

# 工作仓库
git clone git@github-work:company/repo.git
```

## 📋 快速检查清单

- [ ] SSH密钥已生成
- [ ] SSH代理正在运行
- [ ] 密钥已添加到SSH代理
- [ ] 公钥已添加到GitHub
- [ ] SSH连接测试成功
- [ ] 仓库克隆成功

## 🔧 实用命令汇总

```powershell
# 查看SSH密钥列表
ssh-add -l

# 删除所有密钥
ssh-add -D

# 重新添加密钥
ssh-add "$env:USERPROFILE\.ssh\id_ed25519"

# 详细测试连接
ssh -vT git@github.com

# 查看Git远程仓库配置
git remote -v

# 设置Git用户信息
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## 🚀 下一步

配置完成后，您就可以：
1. 使用SSH URL克隆仓库
2. 推送代码无需输入密码
3. 享受更安全的Git操作体验

如果遇到任何问题，请参考上面的故障排除部分！
