# AQUAMIND - Deployment Guide (Windows)

**Version:** 1.0.0  
**Date:** February 26, 2026  
**Status:** Production Ready ✅

---

## 📋 Quick Start (3 Options)

### **Option 1: One-Click Deployment (Recommended) 🎯**

Double-click on:
```
deploy.bat
```

This will:
1. ✅ Check Docker Desktop installation
2. ✅ Start Docker Desktop automatically (if not running)
3. ✅ Build all services
4. ✅ Deploy the application
5. ✅ Wait for all services to be ready
6. ✅ Show access information
7. ✅ Optionally open browser

---

### **Option 2: PowerShell Deployment 🚀**

Open PowerShell and run:

```powershell
# Navigate to project root
cd "c:\Users\user\Desktop\PROJET _PROJET\AQUAMIND"

# Execute deployment script
powershell -ExecutionPolicy Bypass -File deploy-aquamind.ps1 -Action deploy
```

**Actions available:**
- `deploy` — Full deployment (default)
- `status` — Show service status
- `logs` — View live logs
- `down` — Stop all services
- `restart` — Restart all services
- `health` — Run health check

Examples:
```powershell
# View status
powershell -ExecutionPolicy Bypass -File deploy-aquamind.ps1 -Action status

# View logs
powershell -ExecutionPolicy Bypass -File deploy-aquamind.ps1 -Action logs

# Health check
powershell -ExecutionPolicy Bypass -File deploy-aquamind.ps1 -Action health
```

---

### **Option 3: Manual Deployment 🔧**

If you prefer manual control:

```powershell
# Start Docker Desktop first (Windows + Docker Desktop)
# Then in PowerShell:

cd "c:\Users\user\Desktop\PROJET _PROJET\AQUAMIND"

# Copy .env configuration
Copy-Item .env.example .env

# Start services
docker-compose up -d --build

# Wait 30-60 seconds for startup
# Then check status
docker-compose ps
```

---

## 🌐 Access Information

Once deployed, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Landing Page** | http://localhost:3000/index.html | — |
| **Dashboard** | http://localhost:3000/dashboard | — |
| **API Documentation** | http://localhost:8000/docs | — |
| **Swagger UI** | http://localhost:8000/redoc | — |
| **Grafana** | http://localhost:3001 | admin/aquamind |
| **Prometheus** | http://localhost:9090 | — |
| **PostgreSQL** | localhost:5432 | postgres/aquamind |
| **Redis** | localhost:6379 | — |

---

## 🏥 Health Check Monitoring

To monitor service health in real-time:

```powershell
# One-time health check
powershell -ExecutionPolicy Bypass -File health-check.ps1

# Continuous monitoring (updates every 5 seconds)
powershell -ExecutionPolicy Bypass -File health-check.ps1 -Continuous

# Custom interval (check every 10 seconds)
powershell -ExecutionPolicy Bypass -File health-check.ps1 -Interval 10 -Continuous
```

The health check displays:
- ✓ Service status (Healthy / Offline)
- ✓ Docker container status
- ✓ System resource usage (CPU, Memory)
- ✓ Quick access links

---

## 📊 Services Overview

### Backend (FastAPI)
- **Port:** 8000
- **Features:** 30+ REST API endpoints, WebSocket support
- **Health:** http://localhost:8000/health
- **Docs:** http://localhost:8000/docs

### Frontend (React + Vite)
- **Port:** 3000
- **Pages:** Dashboard, Maps, Alerts, Forecasts, Optimization, Agriculture, Analytics
- **Landing:** http://localhost:3000/index.html
- **App:** http://localhost:3000/dashboard

### Database (PostgreSQL + TimescaleDB)
- **Port:** 5432
- **Database:** aquamind
- **Tables:** 6 (users, hydrological_data, forecasts, alerts, subscriptions, audit_log)
- **Features:** Time-series optimization, PostGIS for geospatial

### Cache (Redis)
- **Port:** 6379
- **Purpose:** Session storage, real-time data caching

### Monitoring (Prometheus + Grafana)
- **Prometheus:** http://localhost:9090 (metrics collection)
- **Grafana:** http://localhost:3001 (visualization, admin/aquamind)

---

## 🛠 Useful Commands

### View Service Status
```powershell
docker-compose ps
```

### View Live Logs
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Restart Services
```powershell
# All services
docker-compose restart

# Specific service
docker-compose restart backend
```

### Stop Services
```powershell
docker-compose down
```

### Stop and Remove Data
```powershell
docker-compose down -v
```

### Rebuild Services
```powershell
docker-compose up -d --build
```

### Execute Commands in Container
```powershell
# Run Python command in backend
docker-compose exec backend python -c "print('hello')"

# Access database
docker-compose exec postgres psql -U postgres -d aquamind
```

---

## 🔍 Troubleshooting

### Problem: Docker Desktop Not Found
**Solution:**
1. Download from https://www.docker.com/products/docker-desktop
2. Run installer
3. Restart your computer
4. Run `deploy.bat` again

### Problem: Port Already in Use
**Solution:**
```powershell
# Check which process uses the port
netstat -ano | findstr :3000

# Kill the process (replace PID)
taskkill /PID <PID> /F

# Or change ports in .env file
```

### Problem: Services Won't Start
**Solution:**
```powershell
# Check logs
docker-compose logs

# Reset everything
docker-compose down -v

# Rebuild
docker-compose up -d --build
```

### Problem: Database Connection Error
**Solution:**
```powershell
# Reset database
docker-compose down -v
docker-compose up -d

# Or manually initialize
docker-compose exec postgres psql -U postgres -f /init-db.sql
```

### Problem: Out of Disk Space
**Solution:**
```powershell
# Clean up Docker
docker system prune -a

# Remove volumes
docker volume prune
```

---

## 📈 Performance Metrics

Once deployed with Grafana, you can monitor:

- **Frontend Performance:** Page load times, requests/sec
- **Backend Performance:** API response times, requests/sec
- **Database Performance:** Query times, connections
- **System Resources:** CPU, Memory, Disk usage
- **Error Rates:** 4xx/5xx errors, exceptions

**Grafana Dashboard:** http://localhost:3001 (admin/aquamind)

---

## 🚀 Next Steps

1. **View Landing Page:** http://localhost:3000/index.html
2. **Explore Dashboard:** http://localhost:3000/dashboard
3. **Check API Docs:** http://localhost:8000/docs
4. **Monitor Services:** http://localhost:3001 (Grafana)
5. **Review Logs:** `docker-compose logs -f`

---

## 📞 Support

For issues or questions:

1. **Check logs:** `docker-compose logs -f`
2. **Run health check:** `health-check.ps1`
3. **Review documentation:** `README.md`, `QUICKSTART.md`
4. **Check API docs:** http://localhost:8000/docs

---

## 📝 Notes

- 🔐 Default credentials are in `.env` file
- 📊 Data is persisted in Docker volumes
- 🔄 To reset data: `docker-compose down -v`
- 🌐 Services are accessible on `localhost` only by default
- 🚀 For production, see `README.md` for cloud deployment options

---

**Status:** ✅ Production Ready | **Last Updated:** February 26, 2026
