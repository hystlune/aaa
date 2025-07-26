# PowerShell 升级和 GitHub Copilot 优化指南

## 🚀 PowerShell 升级步骤

### 方法一：使用 winget（推荐）
```powershell
# 安装最新版 PowerShell 7
winget install Microsoft.PowerShell

# 或者安装预览版
winget install Microsoft.PowerShell.Preview
```

### 方法二：使用官方安装脚本
```powershell
# 安装PowerShell 7
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
```

### 方法三：手动下载安装
- 访问：https://github.com/PowerShell/PowerShell/releases
- 下载最新的 `.msi` 安装包
- 运行安装程序

## 📁 配置文件位置

### Windows PowerShell 5.1
```
$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

### PowerShell 7
```
$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

## 🔧 配置安装步骤

### 1. 创建配置文件目录
```powershell
# Windows PowerShell 5.1
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Documents\WindowsPowerShell"

# PowerShell 7
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Documents\PowerShell"
```

### 2. 复制配置文件
```powershell
# 复制 Windows PowerShell 配置
Copy-Item "Microsoft.PowerShell_profile.ps1" "$env:USERPROFILE\Documents\WindowsPowerShell\"

# 复制 PowerShell 7 配置
Copy-Item "Microsoft.PowerShell7_profile.ps1" "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
```

### 3. 设置执行策略（如果需要）
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🎯 VS Code 中的 PowerShell 设置

已在 `settings.json` 中配置的优化设置：

### 终端配置
- 默认使用 PowerShell
- 支持 PowerShell 7 (pwsh.exe)
- 优化的字体和大小设置

### PowerShell 语言设置
- 语法高亮
- 智能感知增强
- 代码格式化
- 自动补全优化

### 文件关联
- `.ps1` - PowerShell 脚本
- `.psm1` - PowerShell 模块
- `.psd1` - PowerShell 数据文件

## 🚀 GitHub Copilot 优化要点

### 1. 语言识别增强
- 正确的文件关联设置
- PowerShell 语法高亮
- 智能感知配置

### 2. 代码补全优化
- 启用内联建议
- 优化建议触发
- 增强参数提示

### 3. 注释驱动开发
```powershell
# 获取系统信息并格式化输出
# Copilot 会根据这个注释生成相应的 PowerShell 代码

# 批量重命名文件，添加日期前缀
# Copilot 会生成文件重命名的 PowerShell 脚本

# 监控服务状态并发送邮件通知
# Copilot 会生成服务监控和邮件发送的代码
```

## 📋 验证安装

### 检查 PowerShell 版本
```powershell
# Windows PowerShell
$PSVersionTable

# PowerShell 7
pwsh -version
```

### 测试配置文件
```powershell
# 重新加载配置文件
. $PROFILE

# 测试自定义函数
Get-SystemInfo
Test-InternetConnection
```

### VS Code 测试
1. 打开 VS Code
2. 创建新的 `.ps1` 文件
3. 输入 PowerShell 代码测试 Copilot 建议
4. 检查语法高亮是否正常

## 🛠️ 推荐扩展

### VS Code 扩展
- `ms-vscode.powershell` - PowerShell 官方扩展
- `github.copilot` - GitHub Copilot
- `ms-vscode.vscode-json` - JSON 支持

### PowerShell 模块
```powershell
# 安装有用的模块
Install-Module PSReadLine -Force
Install-Module posh-git -Force
Install-Module Terminal-Icons -Force
Install-Module z -Force
```

## 🎨 主题和字体推荐

### 字体
- Cascadia Code（已配置）
- JetBrains Mono
- Fira Code

### VS Code 主题
- Dark+ (default dark)
- GitHub Dark
- Monokai Pro

## 🔍 故障排除

### 常见问题

1. **执行策略错误**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **配置文件不加载**
   ```powershell
   Test-Path $PROFILE
   . $PROFILE
   ```

3. **PowerShell 7 未找到**
   - 检查 PATH 环境变量
   - 重新安装 PowerShell 7
   - 重启计算机

4. **Copilot 不识别 PowerShell**
   - 检查文件扩展名 (`.ps1`)
   - 验证 VS Code 扩展已安装
   - 重启 VS Code

## 📊 性能优化建议

### PowerShell 性能
- 使用 PowerShell 7（性能更好）
- 启用 PSReadLine 模块
- 优化启动脚本

### VS Code 性能
- 限制打开的文件数量
- 使用工作区设置
- 定期清理扩展

---

🎉 完成这些配置后，您将拥有一个高效的 PowerShell 开发环境，GitHub Copilot 也能更好地识别和协助您的 PowerShell 编程！
