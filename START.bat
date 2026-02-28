@echo off
REM ═══════════════════════════════════════════════════════════════════════════════
REM AQUAMIND - Quick Startup for Windows
REM ═══════════════════════════════════════════════════════════════════════════════

setlocal
title AQUAMIND Deployment Starting...

REM Display welcome message
cls
echo.
echo ======================================================================
echo  AQUAMIND - Quick Startup
echo  Intelligent Water Forecasting System v1.0.0
echo ======================================================================
echo.
echo Step 1: Starting Docker Desktop...
echo.

REM Check if Docker Desktop is installed
if not exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    if not exist "C:\Program Files (x86)\Docker\Docker\Docker Desktop.exe" (
        echo ERROR: Docker Desktop is not installed!
        echo.
        echo Please install Docker Desktop from:
        echo https://www.docker.com/products/docker-desktop
        echo.
        pause
        exit /b 1
    )
)

REM Start Docker Desktop
echo Starting Docker Desktop (this may take a minute)...
echo.

REM Try to start Docker  
if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
) else (
    start "" "C:\Program Files (x86)\Docker\Docker\Docker Desktop.exe"
)

REM Wait for Docker to start
echo Waiting for Docker to be ready (up to 60 seconds)...
timeout /t 5 /nobreak

:wait_docker
docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: Docker is running!
    echo.
    goto docker_ready
) else (
    echo Still waiting for Docker...
    timeout /t 5 /nobreak
    goto wait_docker
)

:docker_ready
echo.
echo ======================================================================
echo Step 2: Starting AQUAMIND services...
echo ======================================================================
echo.

cd /d "%~dp0"

REM Show deployment options
echo Which DEPLOYMENT method would you like?
echo.
echo 1 = Simple (Docker Compose only)
echo 2 = Full (With health check - RECOMMENDED)
echo.
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    goto simple_deploy
) else if "%choice%"=="2" (
    goto full_deploy
) else (
    echo Invalid choice!
    pause
    exit /b 1
)

:simple_deploy
echo.
echo Copying .env configuration...
copy .env.example .env >nul 2>&1
echo Deploying services (this takes 2-5 minutes on first run)...
docker-compose up -d --build
echo.
echo SUCCESS! Services are starting...
echo.
echo Access your services at:
echo   - Landing Page: http://localhost:3000/index.html
echo   - Dashboard:    http://localhost:3000/dashboard
echo   - API Docs:     http://localhost:8000/docs
echo.
pause
exit /b 0

:full_deploy
echo.
echo Copying .env configuration...
copy .env.example .env >nul 2>&1
echo.
echo Running full deployment with health checks...
echo (This script will monitor services startup and show access info)
echo.
powershell -ExecutionPolicy Bypass -File "deploy-aquamind.ps1" -Action "deploy"
pause
exit /b 0
