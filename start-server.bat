@echo off
REM AQUAMIND - Local Server Launcher (Windows)
REM This script launches a simple HTTP server for the frontend

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              🧠 AQUAMIND - Local Server                        ║
echo ║  Le Cerveau des Bassins Africains                             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found! Please install Python 3.8+
    exit /b 1
)

REM Check if we're in the right directory
if not exist "frontend\public\index.html" (
    echo ❌ frontend\public\index.html not found!
    echo Please run this from the AQUAMIND root directory
    exit /b 1
)

echo ✅ Python found
echo.
echo Starting HTTP Server on port 8080...
echo.
echo 🚀 Pages available:
echo    • Landing Page:   http://localhost:8080/
echo    • Dashboard:      http://localhost:8080/dashboard.html
echo    • Forecast:       http://localhost:8080/forecast.html
echo    • Analytics:      http://localhost:8080/analytics.html
echo.
echo Press CTRL+C to stop the server
echo.

REM Change to frontend/public and start server
cd frontend\public

REM Use Python's built-in HTTP server
python -m http.server 8080 --bind 127.0.0.1

echo.
echo Server stopped.
pause
