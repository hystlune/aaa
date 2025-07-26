# PowerShell 7 配置文件 - 增强GitHub Copilot体验
# 位置: $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# 设置编码为UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 导入有用的模块
Import-Module PSReadLine -ErrorAction SilentlyContinue

# PSReadLine设置 - PowerShell 7增强功能
if (Get-Module PSReadLine) {
    # 启用预测智能感知
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    
    # 启用语法高亮
    Set-PSReadLineOption -Colors @{
        Command            = '#FFD700'  # Gold
        Parameter          = '#98FB98'  # PaleGreen
        Operator           = '#FF69B4'  # HotPink
        Variable           = '#87CEEB'  # SkyBlue
        String             = '#32CD32'  # LimeGreen
        Number             = '#4169E1'  # RoyalBlue
        Type               = '#20B2AA'  # LightSeaGreen
        Comment            = '#696969'  # DimGray
        Keyword            = '#FF6347'  # Tomato
        Selection          = '#FFFF00'  # Yellow
        Emphasis           = '#FF4500'  # OrangeRed
        Error              = '#FF0000'  # Red
        InlinePrediction   = '#808080'  # Gray
    }
    
    # 键绑定设置
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
    Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
    Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo
    
    # 智能Tab补全
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key 'Shift+Tab' -Function TabCompletePrevious
    
    # 历史搜索
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# 美化的提示符
function prompt {
    $currentPath = $PWD.Path.Replace($HOME, '~')
    $pathParts = $currentPath -split '\\'
    if ($pathParts.Count -gt 3) {
        $currentPath = "..\" + ($pathParts[-2..-1] -join '\')
    }
    
    $gitBranch = ""
    # 检查Git状态
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitStatus = git rev-parse --abbrev-ref HEAD 2>$null
        if ($gitStatus) {
            $gitBranch = " (git:$gitStatus)"
        }
    }
    
    # 显示PowerShell版本
    $psVersion = "PS$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
    
    Write-Host "[$psVersion] " -NoNewline -ForegroundColor Magenta
    Write-Host "$currentPath" -NoNewline -ForegroundColor Blue
    Write-Host "$gitBranch" -NoNewline -ForegroundColor Yellow
    Write-Host " > " -NoNewline -ForegroundColor Green
    return " "
}

# 增强的别名
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name ls -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String
Set-Alias -Name find -Value Select-String
Set-Alias -Name which -Value Get-Command
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name touch -Value New-Item

# 实用函数集合
function Get-GitStatus { git status $args }
function Get-GitLog { git log --oneline -10 $args }
function Get-GitBranch { git branch $args }

Set-Alias -Name gst -Value Get-GitStatus
Set-Alias -Name gl -Value Get-GitLog
Set-Alias -Name gb -Value Get-GitBranch

function New-Directory {
    <#
    .SYNOPSIS
    创建目录并进入
    #>
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}
Set-Alias -Name mkcd -Value New-Directory

function Get-DirectorySize {
    <#
    .SYNOPSIS
    获取目录大小
    #>
    param([string]$Path = ".")
    $size = (Get-ChildItem -Path $Path -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $sizeInMB = [math]::Round($size / 1MB, 2)
    $sizeInGB = [math]::Round($size / 1GB, 2)
    
    Write-Output "目录: $Path"
    Write-Output "大小: $sizeInMB MB ($sizeInGB GB)"
}

function Get-ProcessByPort {
    <#
    .SYNOPSIS
    根据端口查找进程
    #>
    param([int]$Port)
    Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | 
    ForEach-Object { Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue }
}

function Start-ElevatedSession {
    <#
    .SYNOPSIS
    以管理员权限启动新的PowerShell会话
    #>
    Start-Process pwsh -Verb RunAs
}
Set-Alias -Name sudo -Value Start-ElevatedSession

# 快速编辑函数
function Edit-Profile { code $PROFILE }
function Edit-Hosts { sudo notepad C:\Windows\System32\drivers\etc\hosts }

# 系统信息函数
function Get-Weather {
    <#
    .SYNOPSIS
    获取天气信息
    #>
    param([string]$City = "Shanghai")
    try {
        $weather = Invoke-RestMethod -Uri "https://wttr.in/$City?format=3" -TimeoutSec 5
        Write-Output $weather
    }
    catch {
        Write-Warning "无法获取天气信息: $_"
    }
}

# 网络工具函数
function Test-InternetConnection {
    <#
    .SYNOPSIS
    测试网络连接
    #>
    $sites = @("8.8.8.8", "baidu.com", "github.com")
    foreach ($site in $sites) {
        if (Test-Connection -ComputerName $site -Count 1 -Quiet) {
            Write-Host "✅ $site - 连接正常" -ForegroundColor Green
        } else {
            Write-Host "❌ $site - 连接失败" -ForegroundColor Red
        }
    }
}

# 显示启动信息
$welcomeMessage = @"

🚀 PowerShell 7 增强配置已加载！
💻 当前版本: PowerShell $($PSVersionTable.PSVersion)
🔧 GitHub Copilot 优化设置已启用
📁 配置文件: $PROFILE

🛠️  可用的自定义命令:
   📊 Get-SystemInfo        - 系统信息
   🌐 Get-PublicIP          - 公网IP
   🔍 Test-Port            - 端口测试
   📁 Get-DirectorySize     - 目录大小
   🔄 Get-ProcessByPort     - 端口进程
   🌤️  Get-Weather           - 天气信息
   🌍 Test-InternetConnection - 网络测试
   
🎯 快捷别名:
   gst, gl, gb (Git操作)
   mkcd (创建并进入目录)
   sudo (管理员权限)

"@

Write-Host $welcomeMessage -ForegroundColor Cyan
