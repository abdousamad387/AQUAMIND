@echo off
REM ═══════════════════════════════════════════════════════════════════════════════
REM AQUAMIND DEPLOYMENT - One-Click Launcher
REM ═══════════════════════════════════════════════════════════════════════════════
REM This batch file handles Docker Desktop startup and application deployment
REM
REM Features:
REM   - Automatic Docker Desktop detection and startup
REM   - Docker Compose orchestration
REM   - Health check monitoring
REM   - Automatic browser launch
REM
REM Usage: Run this file directly or from command line
REM ═══════════════════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion
title AQUAMIND Deployment - Windows

REM Get the script directory
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%

REM ═══════════════════════════════════════════════════════════════════════════════
REM DISPLAY HEADER
REM ═══════════════════════════════════════════════════════════════════════════════

cls
echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo.
echo                    AQUAMIND DEPLOYMENT SCRIPT - WINDOWS
echo                  Intelligent Water Forecasting System v1.0.0
echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo.

REM ═══════════════════════════════════════════════════════════════════════════════
REM FUNCTION: Display colored output
REM ═══════════════════════════════════════════════════════════════════════════════

echo Checking prerequisites...
echo.

REM ═══════════════════════════════════════════════════════════════════════════════
REM CHECK DOCKER INSTALLATION
REM ═══════════════════════════════════════════════════════════════════════════════

echo [*] Checking Docker installation...
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Docker is not installed
    echo.
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
) else (
    echo [OK] Docker is installed
)

REM ═══════════════════════════════════════════════════════════════════════════════
REM CHECK DOCKER RUNNING
REM ═══════════════════════════════════════════════════════════════════════════════

echo [*] Checking if Docker is running...
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Docker Desktop is not running
    echo [*] Attempting to start Docker Desktop...
    
    set "DOCKER_PATH=C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if exist "!DOCKER_PATH!" (
        echo [*] Launching Docker Desktop...
        start "" "!DOCKER_PATH!"
        echo [*] Waiting for Docker to start (this may take 30-60 seconds)...
        
        setlocal enabledelayedexpansion
        set "count=0"
        :wait_docker
        timeout /t 2 /nobreak >nul
        docker ps >nul 2>&1
        if %errorlevel% equ 0 (
            echo [OK] Docker is now running
            goto docker_ready
        )
        set /a count+=1
        if %count% lss 15 (
            echo [*] Waiting... (!count!/30)
            goto wait_docker
        ) else (
            echo [!] Docker did not start in time, continuing anyway...
        )
    ) else (
        echo [X] Docker Desktop not found at expected location
        echo [*] Checking alternative locations...
        if exist "C:\Program Files (x86)\Docker\Docker\Docker Desktop.exe" (
            start "" "C:\Program Files (x86)\Docker\Docker\Docker Desktop.exe"
            timeout /t 30 /nobreak
        ) else (
            echo [X] Unable to locate Docker Desktop
            pause
            exit /b 1
        )
    )
) else (
    echo [OK] Docker is running
)

:docker_ready

REM ═══════════════════════════════════════════════════════════════════════════════
REM CHECK DOCKER COMPOSE
REM ═══════════════════════════════════════════════════════════════════════════════

echo [*] Checking Docker Compose...
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Docker Compose is not installed
    pause
    exit /b 1
) else (
    echo [OK] Docker Compose is installed
)

REM ═══════════════════════════════════════════════════════════════════════════════
REM CHECK PROJECT FILES
REM ═══════════════════════════════════════════════════════════════════════════════

echo [*] Checking project files...
if not exist "%PROJECT_ROOT%docker-compose.yml" (
    echo [X] docker-compose.yml not found
    pause
    exit /b 1
) else (
    echo [OK] docker-compose.yml found
)

if not exist "%PROJECT_ROOT%.env" (
    echo [!] .env file not found
    if exist "%PROJECT_ROOT%.env.example" (
        echo [*] Creating .env from .env.example...
        copy "%PROJECT_ROOT%.env.example" "%PROJECT_ROOT%.env" >nul
        echo [OK] .env created
    ) else (
        echo [X] .env.example not found
        pause
        exit /b 1
    )
) else (
    echo [OK] .env file exists
)

echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo.
echo [*] All prerequisites checked!
echo [*] Starting deployment...
echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo.

REM ═══════════════════════════════════════════════════════════════════════════════
REM DEPLOY APPLICATION
REM ═══════════════════════════════════════════════════════════════════════════════

cd /d "%PROJECT_ROOT%"

echo [*] Stopping existing containers (if any)...
docker-compose down --volumes 2>nul

echo [*] Building and starting services...
echo [*] This may take 2-5 minutes on first run...
echo.

docker-compose up -d --build

if %errorlevel% neq 0 (
    echo [X] Deployment failed
    echo.
    echo For troubleshooting, check logs with:
    echo   docker-compose logs
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo.
echo [OK] Deployment started successfully!
echo.
echo [*] Waiting for services to be ready (this takes 30-60 seconds)...
echo.

REM ═══════════════════════════════════════════════════════════════════════════════
REM WAIT FOR SERVICES
REM ═══════════════════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion
set "wait_count=0"

:wait_services
echo [*] Checking services... (!wait_count!/30)

timeout /t 2 /nobreak >nul

REM Try to connect to frontend
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'http://localhost:3000' -TimeoutSec 1 -ErrorAction SilentlyContinue | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
set "frontend_ready=%errorlevel%"

REM Try to connect to backend
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'http://localhost:8000/docs' -TimeoutSec 1 -ErrorAction SilentlyContinue | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
set "backend_ready=%errorlevel%"

if %frontend_ready% equ 0 if %backend_ready% equ 0 (
    echo [OK] Services are ready!
    goto services_ready
)

set /a wait_count+=1
if %wait_count% lss 30 (
    goto wait_services
)

:services_ready

echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo.
echo [OK] AQUAMIND is now running!
echo.

REM ═══════════════════════════════════════════════════════════════════════════════
REM DISPLAY ACCESS INFORMATION
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo ┌─ SERVICES DISPONIBLES ──────────────────────────────────────────────┐
echo │                                                                      │
echo │  🎨 Landing Page         http://localhost:3000/index.html           │
echo │  📊 Dashboard            http://localhost:3000/dashboard            │
echo │  🔌 API Documentation    http://localhost:8000/docs                 │
echo │  📈 Grafana              http://localhost:3001                      │
echo │     (ID: admin / Pass: aquamind)                                    │
echo │  🔍 Prometheus           http://localhost:9090                      │
echo │                                                                      │
echo └──────────────────────────────────────────────────────────────────────┘
echo.

REM ═══════════════════════════════════════════════════════════════════════════════
REM OFFER TO OPEN BROWSER
REM ═══════════════════════════════════════════════════════════════════════════════

echo [?] Do you want to open the Landing Page in your browser? (Y/N)
set /p "open_browser="
if /i "%open_browser%"=="Y" (
    echo [*] Opening browser...
    start http://localhost:3000/index.html
)

echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo.
echo [OK] Deployment complete! Your application is running.
echo.
echo Useful commands:
echo   - View logs:        docker-compose logs -f
echo   - Stop services:    docker-compose down
echo   - Restart services: docker-compose restart
echo   - Health check:     powershell -ExecutionPolicy Bypass -File health-check.ps1
echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo.

pause
