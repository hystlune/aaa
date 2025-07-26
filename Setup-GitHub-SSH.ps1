# GitHub SSH 自动配置脚本
# 请以管理员权限运行PowerShell执行此脚本

Write-Host "🔐 开始配置GitHub SSH连接..." -ForegroundColor Green
Write-Host ""

# 第一步：检查并安装OpenSSH
Write-Host "第一步：检查OpenSSH安装状态..." -ForegroundColor Yellow

try {
    $sshKeygenPath = Get-Command ssh-keygen -ErrorAction Stop
    Write-Host "✅ OpenSSH已安装: $($sshKeygenPath.Source)" -ForegroundColor Green
} catch {
    Write-Host "❌ OpenSSH未安装，正在安装..." -ForegroundColor Red
    
    try {
        # 尝试安装OpenSSH客户端
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
        Write-Host "✅ OpenSSH客户端安装完成" -ForegroundColor Green
    } catch {
        Write-Host "❌ 无法安装OpenSSH，请手动安装或使用管理员权限" -ForegroundColor Red
        Write-Host "手动安装命令：Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0" -ForegroundColor Cyan
        exit 1
    }
}

# 第二步：创建SSH目录
Write-Host "第二步：创建SSH目录..." -ForegroundColor Yellow
$sshDir = "$env:USERPROFILE\.ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    Write-Host "✅ SSH目录已创建: $sshDir" -ForegroundColor Green
} else {
    Write-Host "✅ SSH目录已存在: $sshDir" -ForegroundColor Green
}

# 第三步：生成SSH密钥
Write-Host "第三步：生成SSH密钥..." -ForegroundColor Yellow

$keyPath = "$sshDir\id_ed25519"
$pubKeyPath = "$keyPath.pub"

if (Test-Path $pubKeyPath) {
    Write-Host "⚠️  SSH密钥已存在，是否要重新生成？" -ForegroundColor Yellow
    $response = Read-Host "输入 'y' 重新生成，其他键跳过"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Remove-Item $keyPath -ErrorAction SilentlyContinue
        Remove-Item $pubKeyPath -ErrorAction SilentlyContinue
    } else {
        Write-Host "✅ 使用现有SSH密钥" -ForegroundColor Green
        $generateKey = $false
    }
}

if (-not (Test-Path $pubKeyPath)) {
    Write-Host "请输入您的GitHub邮箱地址："
    $email = Read-Host "邮箱"
    
    if ([string]::IsNullOrWhiteSpace($email)) {
        $email = "your_email@example.com"
        Write-Host "使用默认邮箱：$email" -ForegroundColor Cyan
    }
    
    Write-Host "正在生成SSH密钥..." -ForegroundColor Cyan
    ssh-keygen -t ed25519 -C $email -f $keyPath -N ""
    
    if (Test-Path $pubKeyPath) {
        Write-Host "✅ SSH密钥生成成功" -ForegroundColor Green
    } else {
        Write-Host "❌ SSH密钥生成失败" -ForegroundColor Red
        exit 1
    }
}

# 第四步：启动SSH代理
Write-Host "第四步：配置SSH代理..." -ForegroundColor Yellow

try {
    # 检查ssh-agent服务
    $sshAgentService = Get-Service ssh-agent -ErrorAction SilentlyContinue
    if ($sshAgentService) {
        if ($sshAgentService.Status -ne 'Running') {
            Set-Service -Name ssh-agent -StartupType Automatic
            Start-Service ssh-agent
            Write-Host "✅ SSH代理服务已启动" -ForegroundColor Green
        } else {
            Write-Host "✅ SSH代理服务已运行" -ForegroundColor Green
        }
    }
    
    # 添加密钥到SSH代理
    ssh-add $keyPath
    Write-Host "✅ SSH密钥已添加到代理" -ForegroundColor Green
    
} catch {
    Write-Host "⚠️  SSH代理配置可能有问题，但密钥已生成" -ForegroundColor Yellow
}

# 第五步：显示公钥
Write-Host "第五步：获取公钥内容..." -ForegroundColor Yellow

if (Test-Path $pubKeyPath) {
    $publicKey = Get-Content $pubKeyPath -Raw
    Write-Host "✅ 您的SSH公钥内容：" -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host $publicKey -ForegroundColor White
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    
    # 复制到剪贴板
    try {
        Set-Clipboard -Value $publicKey.Trim()
        Write-Host "✅ 公钥已复制到剪贴板" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  无法复制到剪贴板，请手动复制上面的内容" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ 找不到公钥文件" -ForegroundColor Red
    exit 1
}

# 第六步：指导添加到GitHub
Write-Host ""
Write-Host "第六步：将公钥添加到GitHub..." -ForegroundColor Yellow
Write-Host "请按以下步骤操作：" -ForegroundColor Cyan
Write-Host "1. 打开浏览器访问：https://github.com/settings/keys" -ForegroundColor White
Write-Host "2. 点击 'New SSH key' 按钮" -ForegroundColor White
Write-Host "3. Title 填写：$(hostname) - $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor White
Write-Host "4. Key 粘贴上面复制的公钥内容" -ForegroundColor White
Write-Host "5. 点击 'Add SSH key' 保存" -ForegroundColor White
Write-Host ""

Write-Host "完成后按任意键继续测试连接..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# 第七步：测试SSH连接
Write-Host "第七步：测试SSH连接..." -ForegroundColor Yellow

Write-Host "正在测试SSH连接到GitHub..." -ForegroundColor Cyan
$testResult = ssh -T git@github.com 2>&1

if ($testResult -match "successfully authenticated") {
    Write-Host "✅ SSH连接测试成功！" -ForegroundColor Green
    Write-Host $testResult -ForegroundColor Green
    
    # 克隆仓库
    Write-Host ""
    Write-Host "第八步：克隆您的仓库..." -ForegroundColor Yellow
    $repoUrl = "git@github.com:hystlune/aaa.git"
    
    Write-Host "正在克隆仓库：$repoUrl" -ForegroundColor Cyan
    git clone $repoUrl
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 仓库克隆成功！" -ForegroundColor Green
        Write-Host "仓库位置：$(Get-Location)\aaa" -ForegroundColor Green
    } else {
        Write-Host "❌ 仓库克隆失败，请检查仓库URL或权限" -ForegroundColor Red
    }
    
} else {
    Write-Host "❌ SSH连接测试失败" -ForegroundColor Red
    Write-Host "错误信息：$testResult" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查：" -ForegroundColor Yellow
    Write-Host "1. 公钥是否正确添加到GitHub" -ForegroundColor White
    Write-Host "2. GitHub用户名是否正确" -ForegroundColor White
    Write-Host "3. 网络连接是否正常" -ForegroundColor White
}

Write-Host ""
Write-Host "🎉 SSH配置过程完成！" -ForegroundColor Green
Write-Host "如有问题，请参考 'GitHub-SSH-配置指南.md' 文件" -ForegroundColor Cyan
