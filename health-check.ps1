# AQUAMIND HEALTH CHECK SCRIPT
# Monitors the health of all services

param(
    [int]$Interval = 5,
    [switch]$Continuous = $false
)

function Test-PortOpen {
    param($Host, $Port, [int]$Timeout = 2)
    try {
        $socket = New-Object System.Net.Sockets.TcpClient
        $result = $socket.BeginConnect($Host, $Port, $null, $null)
        $success = $result.AsyncWaitHandle.WaitOne([timespan]::FromSeconds($Timeout), $false)
        $socket.Close()
        return $success
    } catch {
        return $false
    }
}

function Test-HttpHealth {
    param($Url, [int]$ExpectedCode = 200, [int]$Timeout = 2)
    try {
        $response = Invoke-WebRequest -Uri $Url `
            -MaximumRedirection 0 `
            -TimeoutSec $Timeout `
            -SkipHttpErrorCheck `
            -ErrorAction SilentlyContinue
        return $response.StatusCode -eq $ExpectedCode
    } catch {
        return $false
    }
}

function Check-Service {
    param($Service)
    
    if ($Service.Type -eq "HTTP") {
        $url = "http://localhost:$($Service.Port)$($Service.Path)"
        $healthy = Test-HttpHealth -Url $url -ExpectedCode $Service.Expected
    } else {
        $healthy = Test-PortOpen -Host "localhost" -Port $Service.Port
    }
    
    return @{
        Name = $Service.Name
        Port = $Service.Port
        Type = $Service.Type
        Healthy = $healthy
        Timestamp = Get-Date
    }
}

function Get-DockerStatus {
    try {
        $containers = docker ps --format "{{.Names}}`t{{.Status}}" 2>$null
        return $containers
    } catch {
        return $null
    }
}

function Show-Header {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host "AQUAMIND - HEALTH CHECK REPORT" -ForegroundColor Magenta
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Magenta
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host ""
}

function Show-Services-Status {
    Write-Host "SERVICES" -ForegroundColor Cyan
    Write-Host "--------" -ForegroundColor Cyan
    
    $Services = @(
        @{ Name = "Backend"; Port = 8000; Type = "HTTP"; Expected = 200; Path = "/health" },
        @{ Name = "Frontend"; Port = 3000; Type = "HTTP"; Expected = 200; Path = "/" },
        @{ Name = "PostgreSQL"; Port = 5432; Type = "TCP" },
        @{ Name = "Redis"; Port = 6379; Type = "TCP" },
        @{ Name = "Prometheus"; Port = 9090; Type = "HTTP"; Expected = 200; Path = "/" },
        @{ Name = "Grafana"; Port = 3001; Type = "HTTP"; Expected = 200; Path = "/" }
    )
    
    foreach ($Service in $Services) {
        $status = Check-Service -Service $Service
        $statusText = if ($status.Healthy) { "[OK]" } else { "[OFFLINE]" }
        $statusColor = if ($status.Healthy) { "Green" } else { "Red" }
        
        Write-Host ("  " + $Service.Name.PadRight(15) + " : ") -NoNewline -ForegroundColor Cyan
        Write-Host $statusText -ForegroundColor $statusColor
    }
    
    Write-Host ""
}

function Show-Docker-Status {
    Write-Host "DOCKER CONTAINERS" -ForegroundColor Cyan
    Write-Host "-----------------" -ForegroundColor Cyan
    
    $containers = Get-DockerStatus
    if ($containers) {
        foreach ($container in $containers) {
            $parts = $container -split "`t"
            if ($parts.Count -eq 2) {
                Write-Host ("  " + $parts[0].PadRight(25) + " : " + $parts[1]) -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "  No containers found or Docker not running" -ForegroundColor Red
    }
    Write-Host ""
}

function Show-System-Info {
    Write-Host "SYSTEM INFORMATION" -ForegroundColor Cyan
    Write-Host "------------------" -ForegroundColor Cyan
    
    try {
        $cpu = (Get-WmiObject -Query "SELECT LoadPercentage FROM Win32_Processor" | Measure-Object -Property LoadPercentage -Average).Average
        Write-Host ("  CPU Usage:" + " $([math]::Round($cpu, 1))%".PadLeft(10)) -ForegroundColor Cyan
    } catch { }
    
    try {
        $memory = Get-WmiObject -Class Win32_OperatingSystem | Select-Object @{Name='MemoryUsage'; Expression={[math]::Round(100 * ($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / $_.TotalVisibleMemorySize, 2)}}
        Write-Host ("  Memory Usage:" + " $($memory.MemoryUsage)%".PadLeft(8)) -ForegroundColor Cyan
    } catch { }
    
    Write-Host ("  PowerShell:" + " $($PSVersionTable.PSVersion)".PadLeft(12)) -ForegroundColor Cyan
    
    try {
        $dockerVersion = docker --version 2>$null
        Write-Host ("  Docker:" + " $dockerVersion".PadLeft(20)) -ForegroundColor Cyan
    } catch {
        Write-Host "  Docker:         Not installed" -ForegroundColor Red
    }
    
    Write-Host ""
}

function Show-Quick-Links {
    Write-Host "QUICK ACCESS" -ForegroundColor Green
    Write-Host "------------" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Landing Page: http://localhost:3000/index.html" -ForegroundColor Green
    Write-Host "  Dashboard:    http://localhost:3000/dashboard" -ForegroundColor Green
    Write-Host "  API Docs:     http://localhost:8000/docs" -ForegroundColor Green
    Write-Host "  Grafana:      http://localhost:3001 (admin/aquamind)" -ForegroundColor Green
    Write-Host "  Prometheus:   http://localhost:9090" -ForegroundColor Green
    Write-Host ""
}

# Main execution
do {
    Clear-Host
    Show-Header
    Show-Services-Status
    Show-Docker-Status
    Show-System-Info
    Show-Quick-Links
    
    if ($Continuous) {
        Write-Host "Press Ctrl+C to stop | Refreshing in $Interval seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds $Interval
    } else {
        break
    }
} while ($true)
