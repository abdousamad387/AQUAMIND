#!/bin/bash

# AQUAMIND - Local Server Launcher (macOS/Linux)
# This script launches a simple HTTP server for the frontend

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              🧠 AQUAMIND - Local Server                        ║"
echo "║  Le Cerveau des Bassins Africains                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found! Please install Python 3.8+"
    exit 1
fi

echo "✅ Python3 found: $(python3 --version)"
echo ""

# Check if we're in the right directory
if [ ! -f "frontend/public/index.html" ]; then
    echo "❌ frontend/public/index.html not found!"
    echo "Please run this from the AQUAMIND root directory"
    exit 1
fi

echo "Starting HTTP Server on port 8080..."
echo ""
echo "🚀 Pages available:"
echo "   • Landing Page:   http://localhost:8080/"
echo "   • Dashboard:      http://localhost:8080/dashboard.html"
echo "   • Forecast:       http://localhost:8080/forecast.html"
echo "   • Analytics:      http://localhost:8080/analytics.html"
echo ""
echo "Press CTRL+C to stop the server"
echo ""

# Change to frontend/public and start server
cd frontend/public

# Use Python's built-in HTTP server
python3 -m http.server 8080 --bind 127.0.0.1

echo ""
echo "Server stopped."
