# AQUAMIND - Windows Deployment Script
# Usage: .\deploy.ps1 -Command up|down|logs|restart|clean|health
# 
# PowerShell version: 5.1+
# Run as Administrator if needed

param(
    [Parameter(Position=0)]
    [ValidateSet('up', 'down', 'stop', 'logs', 'restart', 'status', 'health', 'clean', 'backup', 'restore', 'help')]
    [string]$Command = 'help',
    
    [Parameter(Position=1)]
    [string]$Service = '',
    
    [Parameter(Position=2)]
    [string]$BackupFile = ''
)

# Configuration
$ProjectName = "AQUAMIND"
$DockerComposeFile = "docker-compose.yml"
$EnvFile = ".env"
$ExampleEnvFile = ".env.example"

# Functions
function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Check-Prerequisites {
    Write-Header "Checking Prerequisites"
    
    # Check Docker
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker is not installed"
        Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
        exit 1
    }
    Write-Success "Docker installed"
    
    # Check Docker Compose
    if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Error "Docker Compose is not installed"
        exit 1
    }
    Write-Success "Docker Compose installed"
    
    # Check Docker daemon
    try {
        docker info | Out-Null
        Write-Success "Docker daemon is running"
    }
    catch {
        Write-Error "Docker daemon is not running"
        Write-Host "Please start Docker Desktop"
        exit 1
    }
    
    # Check .env file
    if (-not (Test-Path $EnvFile)) {
        if (Test-Path $ExampleEnvFile) {
            Write-Warning ".env file not found, creating from .env.example"
            Copy-Item $ExampleEnvFile $EnvFile
            Write-Success ".env file created"
        }
        else {
            Write-Error ".env.example not found"
            exit 1
        }
    }
    Write-Success ".env file exists"
}

function Deploy-Up {
    Write-Header "Starting AQUAMIND Services"
    
    Check-Prerequisites
    
    Write-Host "Pulling latest images..." -ForegroundColor Cyan
    docker-compose pull
    
    Write-Host "Starting containers (this may take 30-40 seconds)..." -ForegroundColor Cyan
    docker-compose up -d
    
    Start-Sleep -Seconds 5
    
    # Check services status
    Write-Header "Service Status"
    docker-compose ps
    
    Write-Header "Access Points"
    Write-Host "Frontend:  http://localhost:3000" -ForegroundColor Green
    Write-Host "Backend:   http://localhost:8000/docs" -ForegroundColor Green
    Write-Host "Grafana:   http://localhost:3001 (admin/aquamind)" -ForegroundColor Green
    Write-Host "Prometheus: http://localhost:9090" -ForegroundColor Green
    
    Write-Success "AQUAMIND deployed successfully!"
}

function Deploy-Down {
    Write-Header "Stopping AQUAMIND Services"
    
    docker-compose down
    Write-Success "All services stopped"
}

function Deploy-Restart {
    Write-Header "Restarting AQUAMIND Services"
    
    docker-compose restart
    Start-Sleep -Seconds 3
    docker-compose ps
    Write-Success "Services restarted"
}

function Deploy-Logs {
    param([string]$ServiceName = '')
    
    Write-Header "Streaming Service Logs"
    Write-Host "Press Ctrl+C to stop"
    Write-Host ""
    
    if ($ServiceName -and $ServiceName -ne 'logs') {
        docker-compose logs -f $ServiceName
    }
    else {
        docker-compose logs -f
    }
}

function Deploy-Status {
    Write-Header "Service Status"
    docker-compose ps
    
    Write-Header "Resource Usage"
    docker stats --no-stream
}

function Deploy-HealthCheck {
    Write-Header "Health Check"
    
    $services = @("backend", "frontend", "postgres", "redis")
    
    foreach ($service in $services) {
        $output = docker-compose ps | Select-String $service
        if ($output -match "Up") {
            Write-Success "$service is running"
        }
        else {
            Write-Error "$service is NOT running"
        }
    }
    
    # Check backend API
    Write-Host ""
    Write-Host "Testing Backend API..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8000/health" -ErrorAction SilentlyContinue
        if ($response.status -eq "healthy") {
            Write-Success "Backend API is healthy"
        }
    }
    catch {
        Write-Error "Backend API is not responding"
    }
    
    # Check frontend
    Write-Host ""
    Write-Host "Testing Frontend..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -ErrorAction SilentlyContinue
        if ($response.Content -match "AQUAMIND") {
            Write-Success "Frontend is responding"
        }
    }
    catch {
        Write-Error "Frontend is not responding"
    }
}

function Deploy-Clean {
    Write-Header "Cleaning AQUAMIND Resources"
    
    Write-Warning "This will REMOVE all containers and volumes"
    $confirmation = Read-Host "Are you sure? (y/N)"
    
    if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
        docker-compose down -v
        Write-Success "All resources cleaned"
        
        Write-Warning "Note: PostgreSQL data has been deleted"
        Write-Warning "Run '.\deploy.ps1 up' to recreate everything"
    }
    else {
        Write-Warning "Cleanup cancelled"
    }
}

function Deploy-Backup {
    Write-Header "Backing Up Database"
    
    $backupDir = ".\backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "$backupDir\aquamind_backup_$timestamp.sql"
    
    docker-compose exec -T postgres pg_dump -U aquamind aquamind | Out-File -FilePath $backupFile -Encoding UTF8
    
    Write-Success "Database backed up to $backupFile"
}

function Deploy-Restore {
    param([string]$File)
    
    Write-Header "Restoring Database"
    
    if (-not $File) {
        Write-Error "Backup file not specified"
        Write-Host "Usage: .\deploy.ps1 restore <backup-file.sql>"
        Write-Host "Available backups:"
        if (Test-Path ".\backups") {
            Get-ChildItem ".\backups" -Filter "*.sql" | ForEach-Object { Write-Host "  $_" }
        }
        else {
            Write-Host "  No backups found"
        }
        return
    }
    
    if (-not (Test-Path $File)) {
        Write-Error "Backup file not found: $File"
        return
    }
    
    Write-Warning "This will overwrite the current database"
    $confirmation = Read-Host "Continue? (y/N)"
    
    if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
        $content = Get-Content $File -Raw
        $content | docker-compose exec -T postgres psql -U aquamind aquamind
        Write-Success "Database restored from $File"
    }
}

function Show-Help {
    Write-Host @"

AQUAMIND Deployment Script

Usage:
  .\deploy.ps1 [COMMAND] [OPTIONS]

Commands:
  up              Start all services
  down|stop       Stop all services
  restart         Restart all services
  logs [service]  Stream service logs (backend, frontend, postgres, redis)
  status          Show service status and resource usage
  health          Run health checks on all services
  clean           Remove all containers and volumes (destructive!)
  backup          Backup PostgreSQL database
  restore <file>  Restore PostgreSQL database from backup
  help            Show this help message

Examples:
  .\deploy.ps1 up              # Start AQUAMIND
  .\deploy.ps1 logs backend    # View backend logs
  .\deploy.ps1 health          # Check system health
  .\deploy.ps1 backup          # Backup database
  .\deploy.ps1 down            # Stop services

Quick Start:
  1. .\deploy.ps1 up
  2. Open http://localhost:3000
  3. .\deploy.ps1 down (when done)

Requirements:
  - Docker Desktop installed and running
  - .env file configured (copy from .env.example)
  - Ports 3000, 8000, 5432, 6379 available
  - PowerShell 5.1 or later

" -ForegroundColor Green
}

# Main
switch ($Command) {
    'up' {
        Deploy-Up
    }
    'down' {
        Deploy-Down
    }
    'stop' {
        Deploy-Down
    }
    'logs' {
        Deploy-Logs $Service
    }
    'restart' {
        Deploy-Restart
    }
    'status' {
        Deploy-Status
    }
    'health' {
        Deploy-HealthCheck
    }
    'clean' {
        Deploy-Clean
    }
    'backup' {
        Deploy-Backup
    }
    'restore' {
        Deploy-Restore $Service
    }
    'help' {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host "Run '.\deploy.ps1 help' for usage information" -ForegroundColor Cyan
        exit 1
    }
}
