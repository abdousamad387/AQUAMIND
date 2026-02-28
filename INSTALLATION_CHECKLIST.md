# ✅ AQUAMIND Installation & Verification Checklist

## 🔍 Pre-Deployment Checklist

### System Requirements
- [ ] OS: Windows 10+, macOS 10.14+, or Linux (Ubuntu 18.04+)
- [ ] RAM: Minimum 8GB (16GB recommended)
- [ ] Disk Space: Minimum 20GB free
- [ ] CPU: Dual-core processor (4+ cores recommended)
- [ ] Internet: Active connection (for Docker image pulls)

### Software Prerequisites
- [ ] Docker Desktop installed (version 20.10+)
  - Windows: [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Mac: [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Linux: `sudo apt install docker.io docker-compose`
- [ ] Git installed (`git --version` returns version)
- [ ] Ports available:
  - [ ] Port 3000 (Frontend)
  - [ ] Port 8000 (Backend API)
  - [ ] Port 5432 (PostgreSQL)
  - [ ] Port 6379 (Redis)
  - [ ] Port 9090 (Prometheus)
  - [ ] Port 3001 (Grafana)

## 📦 Installation Steps

### Step 1: Clone/Navigate to Project
```bash
# Navigate to AQUAMIND directory
cd ~/Desktop/PROJET_PROJET/AQUAMIND

# Initialize git (if not done)
git init
git add .
git commit -m "Initial AQUAMIND deployment"
```

- [ ] Navigated to AQUAMIND directory
- [ ] Can see all files listed in INDEX.md
- [ ] docker-compose.yml exists
- [ ] .env.example exists
- [ ] frontend/ directory exists
- [ ] backend/ directory exists

### Step 2: Configuration
```bash
# Copy environment template to .env
cp .env.example .env

# Edit .env with your settings (optional for basic setup)
# nano .env  # or use your preferred text editor
```

- [ ] .env file created from .env.example
- [ ] Reviewed ports in .env (can stay default)
- [ ] Reviewed database credentials in .env (optional to change)

### Step 3: Start Services (Docker)

**Linux/Mac:**
```bash
bash deploy.sh up
```

**Windows (PowerShell):**
```powershell
.\deploy.ps1 -Command up
```

**Manual Docker (all platforms):**
```bash
docker-compose up -d
```

- [ ] Docker Compose started successfully
- [ ] No error messages in startup
- [ ] All 6 services starting

### Step 4: Wait for Services to Start
```bash
# Check status (repeat until all show "Up")
docker-compose ps

# Should show:
# backend     ... Up
# frontend    ... Up
# postgres    ... Up (healthy)
# redis       ... Up (healthy)
# prometheus  ... Up
# grafana     ... Up
```

- [ ] Waited 30-40 seconds
- [ ] All 6 services show "Up" status
- [ ] No services show "Exit" or "Restarting"

---

## 🌐 Access & Verification

### Step 5: Verify Frontend Access
```
Open: http://localhost:3000
```

**Visual Checklist**:
- [ ] Page loads without errors (no white screen)
- [ ] Header shows "AQUAMIND - Bassin Fleuve Sénégal"
- [ ] Dashboard displays with:
  - [ ] Header with logo
  - [ ] Sidebar with navigation menu
  - [ ] Main dashboard content visible
  - [ ] Alert badge showing (if alerts exist)
  - [ ] KPI cards for discharge/dams
  - [ ] Real-time indicators blinking

### Step 6: Verify Backend API
```
Open: http://localhost:8000/docs
```

**Visual Checklist**:
- [ ] Swagger API documentation loads
- [ ] Lists 30+ endpoints
- [ ] Green "GET /health" endpoint visible
- [ ] Blue "GET /basins" endpoint visible
- [ ] Can expand endpoints without errors

**Functional Check**:
```bash
# Health test
curl http://localhost:8000/health
# Should return: {"status":"healthy"}

# Basins test
curl http://localhost:8000/api/basins
# Should return array of 3 basins
```

- [ ] Health endpoint returns status="healthy"
- [ ] Basins endpoint returns JSON array
- [ ] No 500 errors in responses

### Step 7: Verify Database
```bash
# Check PostgreSQL is running
docker-compose exec postgres pg_isready

# Should return: "accepting connections"
```

- [ ] PostgreSQL accepting connections
- [ ] No connection refused errors

### Step 8: Verify Redis
```bash
# Check Redis is running
docker-compose exec redis redis-cli ping

# Should return: PONG
```

- [ ] Redis responds with PONG
- [ ] Cache is functional

### Step 9: Verify Monitoring (Optional)
```
Prometheus: http://localhost:9090
Grafana: http://localhost:3001 (admin/aquamind)
```

- [ ] Prometheus loads without errors
- [ ] Can see "targets" in Prometheus
- [ ] Grafana loads with login page
- [ ] Can login with admin/aquamind

---

## 📊 Feature Verification Checklist

### Dashboard Page
```
Navigate: http://localhost:3000
```

- [ ] Loads without errors
- [ ] Shows current date/time
- [ ] Display KPIs:
  - [ ] Bakel discharge (should show ~1200 m³/s ± variation)
  - [ ] Matam discharge (should show ~950 m³/s ± variation)
  - [ ] Manantali level (should show percentage)
  - [ ] Energy production (should show GWh/year)
- [ ] Shows alert summary
- [ ] Shows basin statistics
- [ ] Shows 3 forecast method cards
- [ ] Responsive design (looks good on mobile size too)

### Maps Page
```
Click "Cartes" in sidebar
```

- [ ] Map loads with OpenStreetMap tiles
- [ ] Shows 3 dams with red icons
- [ ] Shows 3 stations with blue icons
- [ ] Shows 3 basin circles
- [ ] River topology polyline visible
- [ ] Can click markers to see popups
- [ ] Layer toggle buttons functional
- [ ] Map controls zoom/pan smoothly

### Forecasts Page
```
Click "Prévisions" in sidebar
```

- [ ] Location selector dropdown works
- [ ] 4 forecast cards display (LSTM, Transformer, ConvLSTM, RL)
- [ ] Each card shows:
  - [ ] Prediction value
  - [ ] Confidence score
  - [ ] Lead time
  - [ ] Model name
- [ ] Forecast numbers are realistic (between 600-2500 m³/s)
- [ ] Model summary box shows all 5 models

### Alerts Page
```
Click "Alertes" in sidebar
```

- [ ] Loads without errors
- [ ] Filter buttons work (all/flood/drought/salinity)
- [ ] Shows alert list (if alerts generated)
- [ ] Each alert shows type, location, level, confidence
- [ ] Recommended actions section displays

### Optimization Page
```
Click "Optimisation" in sidebar
```

- [ ] Shows 3 dam cards (Manantali, Diama, Félou)
- [ ] Global score card shows 0-100 score
- [ ] 4 impact cards show metrics:
  - [ ] Energy (GWh)
  - [ ] Irrigation (M m³)
  - [ ] Environment (status)
  - [ ] Safety (status)
- [ ] Scenario analyzer input fields visible
- [ ] Can submit scenario form

### Agriculture Page
```
Click "Agriculture" in sidebar
```

- [ ] Farmer lookup input visible
- [ ] Can enter farmer_id
- [ ] Shows planning recommendations
- [ ] Shows hydrological conditions
- [ ] Shows irrigation calendar grid
- [ ] Shows agricultural alerts

### Analytics Page
```
Click "Analytique" in sidebar
```

- [ ] Shows 4 KPI cards
- [ ] Shows ecosystem services grid
- [ ] Shows historical trends
- [ ] Basin information displays

---

## 🔌 API Endpoint Verification

### Using curl or Postman

**Test Key Endpoints**:

```bash
# 1. Health check (should return instantly)
curl http://localhost:8000/health
# Expected: {"status":"healthy"}

# 2. Get all basins
curl http://localhost:8000/api/basins
# Expected: JSON array with 3 basins

# 3. Get all dams
curl http://localhost:8000/api/dams
# Expected: JSON array with 3 dams

# 4. Get current metrics for Bakel
curl http://localhost:8000/api/locations/bakel/metrics
# Expected: LocationMetrics with discharge, water_level, alert_level, etc.

# 5. Get short-term forecast
curl http://localhost:8000/api/forecast/bakel/short-term?days=10
# Expected: ForecastShortTerm with predictions and confidence

# 6. Get seasonal forecast
curl http://localhost:8000/api/forecast/bakel/seasonal?months=3
# Expected: ForecastSeasonal with season type and probabilities

# 7. Get alerts
curl http://localhost:8000/api/alerts
# Expected: JSON array of alerts (may be empty)

# 8. Get dashboard overview
curl http://localhost:8000/api/dashboard/overview
# Expected: DashboardMetrics with summary data

# 9. Get map data
curl http://localhost:8000/api/dashboard/map-data
# Expected: GeoJSON FeatureCollection with basins, dams, stations
```

- [ ] Health check returns status=healthy
- [ ] Basins endpoint returns 3 basin objects
- [ ] Dams endpoint returns 3 dam objects
- [ ] Locations metrics endpoint returns data
- [ ] Forecast endpoints return predictions
- [ ] Alerts endpoint returns array
- [ ] Dashboard endpoints return data
- [ ] No 500 errors in responses
- [ ] All response times < 500ms

---

## 🚨 Troubleshooting

### Issue: "Docker daemon not running"
**Solution**:
- [ ] Start Docker Desktop
- [ ] On Linux: `sudo systemctl start docker`
- [ ] Wait 30 seconds, try again

### Issue: "Port 3000 already in use"
**Solution**:
- [ ] Find process: `lsof -i :3000` (Mac/Linux)
- [ ] Or change port in docker-compose.yml: `"3002:80"`
- [ ] Restart with new port: `docker-compose up -d`

### Issue: "Database connection failed"
**Solution**:
- [ ] Check PostgreSQL is running: `docker-compose logs postgres`
- [ ] Check database initialized: `docker-compose exec postgres psql -U aquamind -d aquamind -c "SELECT * FROM users;"`
- [ ] If not initialized: `docker-compose down -v && docker-compose up -d`

### Issue: "Frontend white screen"
**Solution**:
- [ ] Check browser console for errors (F12 → Console)
- [ ] Check backend logs: `docker-compose logs backend`
- [ ] Verify backend API responding: `curl http://localhost:8000/health`
- [ ] Clear browser cache: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

### Issue: "API returns 500 errors"
**Solution**:
- [ ] Check backend logs: `docker-compose logs backend -f`
- [ ] Look for Python exceptions
- [ ] If database connection: Verify postgres healthchecks passing
- [ ] Restart backend only: `docker-compose restart backend`

### Issue: "WebSocket connection fails"
**Solution**:
- [ ] Check nginx config includes WebSocket headers (`websocket`)
- [ ] Verify proxy_read_timeout in nginx (should be high)
- [ ] Check firewall not blocking port 8000
- [ ] Restart frontend: `docker-compose restart frontend`

---

## 🧹 Cleanup/Reset

### Stop All Services
```bash
# Linux/Mac
bash deploy.sh down

# Windows PowerShell
.\deploy.ps1 -Command down

# Manual
docker-compose down
```

- [ ] All services stopped
- [ ] No processes on ports 3000, 8000, 5432, 6379

### Full Clean Reset (⚠️ DELETES DATA)
```bash
# Linux/Mac
bash deploy.sh clean

# Windows PowerShell
.\deploy.ps1 -Command clean

# Manual
docker-compose down -v
```

- [ ] All containers removed
- [ ] All volumes deleted
- [ ] Database reset to initial state
- [ ] Ready for fresh start

### Backup Database Before Reset
```bash
# Linux/Mac
bash deploy.sh backup

# Windows PowerShell
.\deploy.ps1 -Command backup

# Manual
docker-compose exec postgres pg_dump -U aquamind aquamind > backup_$(date +%Y%m%d_%H%M%S).sql
```

- [ ] Backup file created in `./backups/`
- [ ] Can restore later if needed

---

## 📈 Performance Verification

### Expected Response Times
| Endpoint | Expected Time | Actual Time |
|----------|---------------|------------|
| /health | <50ms | [ ] |
| /basins | <100ms | [ ] |
| /locations/{id}/metrics | <150ms | [ ] |
| /forecast/{id}/short-term | <500ms | [ ] |
| /forecast/{id}/ensemble | <800ms | [ ] |
| /dashboard/overview | <200ms | [ ] |

**Measure with curl**:
```bash
curl -w "Time: %{time_total}s\n" http://localhost:8000/health
```

- [ ] Most endpoints respond in <500ms
- [ ] Ensemble forecast in <1000ms (expected longer)
- [ ] No 503 errors (service unavailable)

### Resource Usage
```bash
docker stats --no-stream
```

Expected:
- [ ] Backend: <300MB RAM
- [ ] Frontend: <100MB RAM
- [ ] PostgreSQL: <500MB RAM
- [ ] Redis: <50MB RAM
- [ ] Total: <1GB RAM

---

## 📚 Documentation Review

- [ ] Read QUICKSTART.md (start here for quick reference)
- [ ] Read README.md (full documentation)
- [ ] Review INDEX.md (file structure)
- [ ] Review ALERTS_AND_USECASES.md (alert scenarios)
- [ ] Understand Architecture (Mermaid diagram in README)
- [ ] Understand AI Models (5-model ensemble)
- [ ] Know Database Schema (TimescaleDB optimized)

---

## ✅ Final Sign-Off

### All Checks Passed?
- [ ] All prerequisites met
- [ ] All services running
- [ ] Frontend accessible and responsive
- [ ] Backend API responding
- [ ] Database connected
- [ ] All main features working
- [ ] No errors in logs
- [ ] Performance acceptable
- [ ] Documentation reviewed

### Ready for Production?
- [ ] Database backed up (if migrating data)
- [ ] Environment variables secure (.env not in git)
- [ ] SSL/TLS configured (if exposed to internet)
- [ ] Monitoring active (Prometheus/Grafana)
- [ ] Alert notifications configured
- [ ] Backup strategy in place
- [ ] Team trained on dashboard

---

## 🎉 Deployment Complete!

**Status**: ✅ **AQUAMIND is LIVE**

### Next Steps:
1. **Explore**: Spend time understanding each dashboard page
2. **Test**: Run forecasts for different locations
3. **Integrate**: Connect real data sources (Google Earth Engine, weather APIs)
4. **Deploy**: Scale to production environment
5. **Monitor**: Set up alerting and logging

### Support:
- 📖 Full docs: [README.md](README.md)
- 🚀 Quick ref: [QUICKSTART.md](QUICKSTART.md)
- 🗺️ Navigation: [INDEX.md](INDEX.md)
- 🚨 Alerts: [ALERTS_AND_USECASES.md](ALERTS_AND_USECASES.md)

---

**Deployment Date**: ____________  
**Verified By**: ____________  
**Notes**: ____________  

---

**Last Updated**: February 2026 | Version 1.0.0
