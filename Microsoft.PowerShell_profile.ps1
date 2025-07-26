# PowerShell配置文件 - 增强GitHub Copilot体验
# 位置: $env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# 设置编码为UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 设置PowerShell执行策略（如果需要）
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 导入有用的模块
Import-Module PSReadLine -ErrorAction SilentlyContinue

# PSReadLine设置 - 增强命令行体验
if (Get-Module PSReadLine) {
    # 设置预测源为历史记录和插件
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    
    # 设置预测视图模式
    Set-PSReadLineOption -PredictionViewStyle ListView
    
    # 启用语法高亮
    Set-PSReadLineOption -Colors @{
        Command   = 'Yellow'
        Parameter = 'Green'
        Operator  = 'Magenta'
        Variable  = 'Cyan'
        String    = 'DarkGreen'
        Number    = 'Blue'
        Type      = 'DarkCyan'
        Comment   = 'DarkGray'
    }
    
    # 设置键绑定
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
    Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
    
    # Tab 补全设置
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# 自定义提示符
function prompt {
    $currentPath = Split-Path -Leaf -Path (Get-Location)
    $gitBranch = ""
    
    # 检查是否在Git仓库中
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitStatus = git rev-parse --abbrev-ref HEAD 2>$null
        if ($gitStatus) {
            $gitBranch = " ($gitStatus)"
        }
    }
    
    Write-Host "PS " -NoNewline -ForegroundColor Green
    Write-Host "$currentPath" -NoNewline -ForegroundColor Blue
    Write-Host "$gitBranch" -NoNewline -ForegroundColor Yellow
    Write-Host " > " -NoNewline -ForegroundColor White
    return " "
}

# 有用的别名
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String
Set-Alias -Name which -Value Get-Command

# 创建有用的函数
function Get-PublicIP {
    <#
    .SYNOPSIS
    获取公网IP地址
    #>
    try {
        $ip = Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5
        Write-Output "Your public IP: $ip"
    }
    catch {
        Write-Warning "无法获取公网IP: $_"
    }
}

function Test-Port {
    <#
    .SYNOPSIS
    测试端口连通性
    .PARAMETER ComputerName
    目标计算机名或IP
    .PARAMETER Port
    端口号
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,
        
        [Parameter(Mandatory)]
        [int]$Port
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($ComputerName, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(3000, $false)
        
        if ($wait) {
            $tcpClient.EndConnect($connect)
            Write-Output "✅ $ComputerName`:$Port - 连接成功"
        } else {
            Write-Output "❌ $ComputerName`:$Port - 连接超时"
        }
        $tcpClient.Close()
    }
    catch {
        Write-Output "❌ $ComputerName`:$Port - 连接失败: $_"
    }
}

function Get-SystemInfo {
    <#
    .SYNOPSIS
    获取系统信息摘要
    #>
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    $processor = Get-CimInstance -ClassName Win32_Processor
    
    [PSCustomObject]@{
        ComputerName = $computer.Name
        OS = $os.Caption
        Version = $os.Version
        Architecture = $os.OSArchitecture
        TotalMemoryGB = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
        Processor = $processor.Name
        Cores = $processor.NumberOfCores
        LogicalProcessors = $processor.NumberOfLogicalProcessors
    }
}

function Update-PowerShellHelp {
    <#
    .SYNOPSIS
    更新PowerShell帮助文档
    #>
    Write-Host "正在更新PowerShell帮助文档..." -ForegroundColor Yellow
    Update-Help -Force -ErrorAction SilentlyContinue
    Write-Host "帮助文档更新完成！" -ForegroundColor Green
}

# 显示欢迎信息
Write-Host ""
Write-Host "🚀 PowerShell 增强配置已加载！" -ForegroundColor Green
Write-Host "💡 GitHub Copilot 优化设置已启用" -ForegroundColor Cyan
Write-Host ""
Write-Host "可用的自定义命令:" -ForegroundColor Yellow
Write-Host "  Get-PublicIP      - 获取公网IP" -ForegroundColor Gray
Write-Host "  Test-Port         - 测试端口连通性" -ForegroundColor Gray
Write-Host "  Get-SystemInfo    - 获取系统信息" -ForegroundColor Gray
Write-Host "  Update-PowerShellHelp - 更新帮助文档" -ForegroundColor Gray
Write-Host ""
