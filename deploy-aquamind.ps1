# AQUAMIND DEPLOYMENT SCRIPT - Windows PowerShell
# Simple version without special characters to avoid encoding issues

param([string]$Action = "deploy")

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Error-Custom { Write-Host "[ERROR] $args" -ForegroundColor Red }
function Write-Warning-Custom { Write-Host "[WARNING] $args" -ForegroundColor Yellow }
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }

function Test-DockerRunning {
    try {
        $null = docker ps 2>$null
        return $true
    } catch {
        return $false
    }
}

function Start-DockerDesktop {
    Write-Info "Docker Desktop is not running. Attempting to start..."
    $dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    
    if (Test-Path $dockerPath) {
        Write-Info "Launching Docker Desktop..."
        & $dockerPath
        Write-Info "Waiting for Docker to start (up to 30 seconds)..."
        
        $timeout = 30
        $elapsed = 0
        while ($elapsed -lt $timeout) {
            Start-Sleep -Seconds 2
            if (Test-DockerRunning) {
                Write-Success "Docker Desktop is now running!"
                Start-Sleep -Seconds 3
                return $true
            }
            $elapsed += 2
            Write-Host "." -NoNewline -ForegroundColor Cyan
        }
        Write-Host ""
        Write-Warning-Custom "Docker did not start in time, but continuing..."
        return $false
    } else {
        Write-Error-Custom "Docker Desktop not found. Please install it from https://www.docker.com/products/docker-desktop"
        return $false
    }
}

function Test-Prerequisites {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host "CHECKING PREREQUISITES" -ForegroundColor Magenta
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Check Docker
    Write-Info "Checking Docker..."
    if (-not (Test-DockerRunning)) {
        Write-Warning-Custom "Docker is not running"
        Start-DockerDesktop
    } else {
        Write-Success "Docker is running"
    }
    
    # Check Docker Compose
    Write-Info "Checking Docker Compose..."
    try {
        $version = docker-compose --version 2>$null
        Write-Success "Docker Compose found: $version"
    } catch {
        Write-Error-Custom "Docker Compose not found"
        return $false
    }
    
    # Check files
    Write-Info "Checking project files..."
    if (-not (Test-Path "$ProjectRoot\docker-compose.yml")) {
        Write-Error-Custom "docker-compose.yml not found"
        return $false
    }
    Write-Success "docker-compose.yml found"
    
    # Check .env
    Write-Info "Checking .env file..."
    if (-not (Test-Path "$ProjectRoot\.env")) {
        Write-Warning-Custom ".env not found, creating from .env.example..."
        if (Test-Path "$ProjectRoot\.env.example") {
            Copy-Item "$ProjectRoot\.env.example" "$ProjectRoot\.env" -Force
            Write-Success ".env created"
        }
    } else {
        Write-Success ".env exists"
    }
    
    return $true
}

function Deploy-Application {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host "DEPLOYING APPLICATION" -ForegroundColor Magenta
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    Push-Location $ProjectRoot
    try {
        Write-Info "Removing existing containers..."
        docker-compose down --volumes 2>$null
        
        Write-Info "Building and starting services..."
        Write-Host "======================================================================" -ForegroundColor Cyan
        docker-compose up -d --build
        Write-Host "======================================================================" -ForegroundColor Cyan
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker Compose started successfully!"
            return $true
        } else {
            Write-Error-Custom "Error starting docker-compose"
            return $false
        }
    } finally {
        Pop-Location
    }
}

function Wait-ForServices {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host "WAITING FOR SERVICES TO START" -ForegroundColor Magenta
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    $services = @(
        @{ Name = "Backend"; Port = 8000; Path = "/health" },
        @{ Name = "Frontend"; Port = 3000; Path = "/" },
        @{ Name = "Grafana"; Port = 3001; Path = "/" }
    )
    
    $maxWait = 180
    $elapsed = 0
    $interval = 5
    
    while ($elapsed -lt $maxWait) {
        Write-Info "Checking services... ($elapsed/$maxWait sec)"
        
        $allHealthy = $true
        foreach ($service in $services) {
            try {
                $result = Invoke-WebRequest -Uri "http://localhost:$($service.Port)$($service.Path)" `
                    -MaximumRedirection 0 `
                    -ErrorAction SilentlyContinue `
                    -TimeoutSec 2
                Write-Success "$($service.Name) is ready"
            } catch {
                Write-Warning-Custom "$($service.Name) starting..."
                $allHealthy = $false
            }
        }
        
        if ($allHealthy) {
            Write-Success "All services are ready!"
            return $true
        }
        
        Start-Sleep -Seconds $interval
        $elapsed += $interval
        Write-Host "." -NoNewline -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Warning-Custom "Services did not all start in time, but deployment is running."
    return $false
}

function Show-AccessInfo {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "SERVICES AVAILABLE" -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Landing Page:  http://localhost:3000/index.html" -ForegroundColor Green
    Write-Host "Dashboard:     http://localhost:3000/dashboard" -ForegroundColor Green
    Write-Host "API Docs:      http://localhost:8000/docs" -ForegroundColor Green
    Write-Host "Grafana:       http://localhost:3001  (admin / aquamind)" -ForegroundColor Green
    Write-Host "Prometheus:    http://localhost:9090" -ForegroundColor Green
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "USEFUL COMMANDS" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "View logs:       docker-compose logs -f" -ForegroundColor Yellow
    Write-Host "Stop services:   docker-compose down" -ForegroundColor Yellow
    Write-Host "Service status:  docker-compose ps" -ForegroundColor Yellow
    Write-Host "Health check:    powershell -ExecutionPolicy Bypass -File health-check.ps1" -ForegroundColor Yellow
    Write-Host ""
}

function Show-Status {
    Write-Host ""
    Write-Host "SERVICE STATUS:" -ForegroundColor Cyan
    Write-Host ""
    Push-Location $ProjectRoot
    try {
        docker-compose ps
    } finally {
        Pop-Location
    }
}

# MAIN EXECUTION
switch ($Action.ToLower()) {
    "deploy" {
        if (Test-Prerequisites) {
            if (Deploy-Application) {
                Write-Info "Waiting for services to be ready..."
                Wait-ForServices
                Show-AccessInfo
            } else {
                Write-Error-Custom "Deployment failed"
                exit 1
            }
        }
    }
    
    "status" {
        Show-Status
    }
    
    "logs" {
        Push-Location $ProjectRoot
        try {
            docker-compose logs -f
        } finally {
            Pop-Location
        }
    }
    
    "down" {
        Write-Host ""
        Write-Host "Stopping services..." -ForegroundColor Magenta
        Push-Location $ProjectRoot
        try {
            docker-compose down
            Write-Success "Services stopped"
        } finally {
            Pop-Location
        }
    }
    
    "restart" {
        Write-Host ""
        Write-Host "Restarting services..." -ForegroundColor Magenta
        Push-Location $ProjectRoot
        try {
            docker-compose restart
            Write-Success "Services restarted"
        } finally {
            Pop-Location
        }
    }
    
    "health" {
        Push-Location $ProjectRoot
        try {
            & "$ProjectRoot\health-check.ps1"
        } finally {
            Pop-Location
        }
    }
    
    default {
        Write-Error-Custom "Unknown action: $Action"
        Write-Info "Available actions: deploy, status, logs, down, restart, health"
        exit 1
    }
}

Write-Host ""
Write-Success "Done!"
Write-Host ""
