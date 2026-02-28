"""
API FastAPI AQUAMIND - Backend principal.
Endpoints pour dashboards, prévisions, alertes, optimisation.
"""
from fastapi import FastAPI, HTTPException, WebSocket, Query, Depends
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
import json
import asyncio
import numpy as np
from contextlib import asynccontextmanager

from app.services.data_service import DataService
from app.services.forecast_service import ForecastService
from app.schemas.hydrological import (
    Basin, Dam, LocationMetrics, ForecastShortTerm, ForecastSeasonal,
    FloodPrediction, DamOptimization, Alert, DashboardMetrics, SystemStatus,
    SensorReading, EcosystemService
)


# Dépendances
async def get_data_service():
    # En production, utiliser une vraie DB
    return DataService(db=None)


async def get_forecast_service(data_service: DataService = Depends(get_data_service)):
    return ForecastService(data_service)


# Application FastAPI
app = FastAPI(
    title="AQUAMIND API",
    description="Système Intelligent de Prédiction Hydrologique - Bassin Fleuve Sénégal",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==================== HEALTH & STATUS ====================

@app.get("/", tags=["Health"])
async def root():
    """Root endpoint"""
    return {
        "status": "operational",
        "name": "AQUAMIND",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "uptime_percent": 99.97
    }


@app.get("/system/status", response_model=SystemStatus, tags=["System"])
async def get_system_status(data_service: DataService = Depends(get_data_service)):
    """État du système AQUAMIND"""
    return SystemStatus(
        status="operational",
        uptime_percent=99.97,
        last_data_update=datetime.utcnow(),
        next_forecast_batch=datetime.utcnow() + timedelta(hours=6),
        
        backend_status="healthy",
        database_status="healthy",
        ai_models_status="healthy",
        
        active_users=int(np.random.random() * 500 + 100),
        total_alerts_24h=int(np.random.random() * 20 + 5),
        model_predictions_24h=int(np.random.random() * 1000 + 500)
    )


# ==================== BASSINS & BARRAGES ====================

@app.get("/basins", response_model=List[Basin], tags=["Geography"])
async def get_basins(data_service: DataService = Depends(get_data_service)):
    """Tous les bassins versants"""
    return data_service.get_all_basins()


@app.get("/basins/{basin_id}", response_model=Basin, tags=["Geography"])
async def get_basin(basin_id: str, data_service: DataService = Depends(get_data_service)):
    """Détail d'un bassin"""
    basin = data_service.get_basin(basin_id)
    if not basin:
        raise HTTPException(status_code=404, detail="Basin not found")
    return basin


@app.get("/dams", response_model=List[Dam], tags=["Infrastructure"])
async def get_dams(data_service: DataService = Depends(get_data_service)):
    """Tous les barrages"""
    return data_service.get_all_dams()


@app.get("/dams/{dam_id}", response_model=Dam, tags=["Infrastructure"])
async def get_dam(dam_id: str, data_service: DataService = Depends(get_data_service)):
    """Détail d'un barrage"""
    dam = data_service.get_dam(dam_id)
    if not dam:
        raise HTTPException(status_code=404, detail="Dam not found")
    return dam


# ==================== DONNÉES EN TEMPS RÉEL ====================

@app.get("/locations/{location_id}/metrics", response_model=LocationMetrics, tags=["RealTime"])
async def get_location_metrics(
    location_id: str,
    data_service: DataService = Depends(get_data_service)
):
    """Métriques actuelles d'une localisation (station, barrage, bassin)"""
    return await data_service.get_location_metrics(location_id)


@app.get("/sensors/{station_id}/reading", response_model=SensorReading, tags=["RealTime"])
async def get_sensor_reading(
    station_id: str,
    data_service: DataService = Depends(get_data_service)
):
    """Dernière lecture d'un capteur IoT"""
    return await data_service.get_sensor_reading(station_id)


@app.get("/locations/{location_id}/historical", tags=["Historical"])
async def get_historical_data(
    location_id: str,
    days_back: int = Query(90, ge=7, le=365),
    data_service: DataService = Depends(get_data_service)
):
    """Données historiques pour analyse/entraînement"""
    df = await data_service.get_historical_data(location_id, days_back)
    return {
        "location_id": location_id,
        "days_back": days_back,
        "records": df.to_dict(orient='records'),
        "statistics": {
            "discharge_m3_s": {
                "mean": float(df['discharge_m3_s'].mean()),
                "std": float(df['discharge_m3_s'].std()),
                "min": float(df['discharge_m3_s'].min()),
                "max": float(df['discharge_m3_s'].max())
            }
        }
    }


# ==================== PRÉVISIONS ====================

@app.get("/forecast/{location_id}/short-term", response_model=ForecastShortTerm, tags=["Forecast"])
async def forecast_short_term(
    location_id: str,
    days: int = Query(10, ge=7, le=15),
    forecast_service: ForecastService = Depends(get_forecast_service)
):
    """Prévision court terme (7-15 jours) - LSTM"""
    return await forecast_service.forecast_short_term(location_id, days)


@app.get("/forecast/{location_id}/seasonal", response_model=ForecastSeasonal, tags=["Forecast"])
async def forecast_seasonal(
    location_id: str,
    months: int = Query(3, ge=1, le=12),
    forecast_service: ForecastService = Depends(get_forecast_service)
):
    """Prévision saisonnière (3-6 mois) - Transformers"""
    return await forecast_service.forecast_seasonal(location_id, months)


@app.get("/forecast/{location_id}/flood", response_model=FloodPrediction, tags=["Forecast"])
async def forecast_flood(
    location_id: str,
    forecast_service: ForecastService = Depends(get_forecast_service)
):
    """Prédiction spatiale des inondations (résolution 30m)"""
    return await forecast_service.predict_flood(location_id)


@app.get("/forecast/{location_id}/ensemble", tags=["Forecast"])
async def forecast_ensemble(
    location_id: str,
    days: int = Query(10, ge=7, le=15),
    forecast_service: ForecastService = Depends(get_forecast_service)
):
    """Ensemble complet: court terme + saisonnier + inondations + alertes"""
    return await forecast_service.get_ensemble_forecast(location_id, days)


# ==================== ALERTES ====================

@app.get("/alerts", response_model=List[Dict], tags=["Alerts"])
async def get_active_alerts(
    alert_type: Optional[str] = None,
    min_level: str = "vigilance"
):
    """Alertes actuelles actives"""
    # Simule alertes
    now = datetime.utcnow()
    alerts = [
        {
            "alert_id": "alert_001",
            "alert_type": "flood",
            "alert_level": "vigilance",
            "location": "Matam",
            "trigger_date": now.isoformat(),
            "event_expected_date": (now + timedelta(days=10)).isoformat(),
            "lead_time_days": 10,
            "message_fr": "Risque de crue modéré à Matam dans 10 jours",
            "confidence": 0.88
        }
    ]
    
    if alert_type:
        alerts = [a for a in alerts if a['alert_type'] == alert_type]
    
    return alerts


@app.post("/alerts/subscribe", tags=["Alerts"])
async def subscribe_alert(
    location_id: str,
    alert_types: List[str] = ["flood", "drought"]
):
    """S'abonner aux alertes"""
    return {
        "subscription_id": f"sub_{location_id}_{datetime.utcnow().timestamp()}",
        "location_id": location_id,
        "alert_types": alert_types,
        "status": "active",
        "message": "Subscription successful"
    }


# ==================== OPTIMISATION ====================

@app.get("/optimization/dams", response_model=DamOptimization, tags=["Optimization"])
async def optimize_dams(
    forecast_days: int = Query(10, ge=7, le=15),
    forecast_service: ForecastService = Depends(get_forecast_service)
):
    """Optimisation multi-objectifs des 3 barrages (Manantali, Diama, Félou)"""
    return await forecast_service.optimize_dams(forecast_days)


@app.post("/optimization/scenario", tags=["Optimization"])
async def scenario_analysis(
    scenario: Dict[str, Any]
):
    """
    Analyse de scénario: 
    {'manantali_discharge_m3_s': 1500, 'diama_discharge_m3_s': 1200, ...}
    Retourne impacts prédits.
    """
    return {
        "scenario_id": f"scenario_{datetime.utcnow().timestamp()}",
        "input": scenario,
        "predicted_energy_gwh": 150.0,
        "predicted_irrigation_m3": 50e6,
        "predicted_salinity_risk": 0.2,
        "predicted_flood_risk": 0.15,
        "environmental_impact": "moderate_positive"
    }


# ==================== TABLEAUX DE BORD ====================

@app.get("/dashboard/overview", tags=["Dashboard"])
async def dashboard_overview(data_service: DataService = Depends(get_data_service)):
    """Aperçu dashboard principal"""
    metrics_bakel = await data_service.get_location_metrics("station_001")
    metrics_matam = await data_service.get_location_metrics("station_002")
    
    return {
        "timestamp": datetime.utcnow().isoformat(),
        
        # État hydro général
        "general_status": {
            "bakel": {
                "discharge_m3_s": metrics_bakel.current_discharge,
                "water_status": metrics_bakel.water_status,
                "alert_level": metrics_bakel.alert_level
            },
            "matam": {
                "discharge_m3_s": metrics_matam.current_discharge,
                "water_status": metrics_matam.water_status,
                "alert_level": metrics_matam.alert_level
            }
        },
        
        # Infrastructure
        "dams": {
            "manantali": {"level_percent": 62.0, "discharge_m3_s": 1200},
            "diama": {"level_percent": 68.0, "discharge_m3_s": 950},
            "felou": {"level_percent": 71.0, "discharge_m3_s": 400}
        },
        
        # Alertes actives
        "active_alerts": 2,
        "alerts": [
            {
                "type": "flood",
                "location": "Matam",
                "confidence": 0.88,
                "days_ahead": 10
            }
        ],
        
        # Statistiques
        "statistics": {
            "sensors_operational": 50,
            "sensors_total": 95,
            "models_running": 5,
            "last_forecast": (datetime.utcnow() - timedelta(hours=2)).isoformat()
        }
    }


@app.get("/dashboard/map-data", tags=["Dashboard"])
async def dashboard_map_data(data_service: DataService = Depends(get_data_service)):
    """Données pour carte Leaflet"""
    basins = data_service.get_all_basins()
    dams = data_service.get_all_dams()
    
    stations = {
        "station_001": {
            "name": "Bakel",
            "coords": {"lat": 14.22, "lon": -11.92},
            "discharge": 1200
        },
        "station_002": {
            "name": "Matam",
            "coords": {"lat": 14.13, "lon": -11.77},
            "discharge": 950
        },
        "station_003": {
            "name": "Kaédi",
            "coords": {"lat": 13.83, "lon": -13.15},
            "discharge": 600
        }
    }
    
    return {
        "basins": [
            {
                "id": b.id,
                "name": b.name,
                "population": b.population,
                "area_km2": b.area_km2,
                "coordinates": b.coordinates
            }
            for b in basins
        ],
        "dams": [
            {
                "id": d.id,
                "name": d.name,
                "level_percent": d.current_level_percent,
                "capacity_m3": d.capacity_m3,
                "power_capacity_mw": d.power_capacity_mw,
                "coordinates": d.coordinates
            }
            for d in dams
        ],
        "stations": stations
    }


@app.get("/dashboard/statistics", tags=["Dashboard"])
async def dashboard_statistics(data_service: DataService = Depends(get_data_service)):
    """Statistiques et KPIs"""
    return {
        "timestamp": datetime.utcnow().isoformat(),
        "basin_summary": {
            "total_population": 15000000,
            "total_area_km2": 300000,
            "total_irrigation_km2": 220000,
            "total_energy_capacity_mw": 280
        },
        "hydrological": {
            "avg_discharge_m3_s": 1100,
            "total_water_stored_m3": 12.1e9,
            "storage_percent": 65.0
        },
        "economic": {
            "expected_energy_production_gwh": 650,
            "irrigation_area_served_km2": 220000,
            "agricultural_population": 9750000
        },
        "alerts_24h": 5,
        "forecast_confidence_avg": 0.86
    }


# ==================== AGRICULTURE & IMPACTS ====================

@app.get("/agriculture/recommendations/{farmer_id}", tags=["Agriculture"])
async def agriculture_recommendations(farmer_id: str):
    """Recommandations agricoles basées sur prévisions"""
    return {
        "farmer_id": farmer_id,
        "location": {"lat": 14.1, "lon": -11.8},
        "crop_type": "rice",
        "recommended_sowing_date": (datetime.utcnow() + timedelta(days=5)).isoformat(),
        "expected_rainfall_mm": 650,
        "expected_yield_increase_percent": 23,
        "confidence": 0.78,
        "irrigation_schedule": {
            "july": 50,
            "august": 80,
            "september": 30
        }
    }


@app.get("/ecosystem/services", response_model=List[EcosystemService], tags=["Ecosystem"])
async def get_ecosystem_services():
    """Services écosystémiques valorisés"""
    return [
        EcosystemService(
            service_id="service_001",
            service_type="carbon_sequestration",
            annual_value_eur=25_000_000,
            tonnes_co2_equivalent=1_200_000,
            affected_area_km2=80000,
            biodiversity_index=0.72,
            trend="improving"
        ),
        EcosystemService(
            service_id="service_002",
            service_type="fish_reproduction",
            annual_value_eur=15_000_000,
            tonnes_co2_equivalent=None,
            affected_area_km2=50000,
            biodiversity_index=0.68,
            trend="stable"
        ),
        EcosystemService(
            service_id="service_003",
            service_type="flood_mitigation",
            annual_value_eur=18_000_000,
            tonnes_co2_equivalent=None,
            affected_area_km2=120000,
            biodiversity_index=0.65,
            trend="improving"
        )
    ]


# ==================== WEBSOCKET (Real-time) ====================

@app.websocket("/ws/live/{location_id}")
async def websocket_endpoint(websocket: WebSocket, location_id: str):
    """WebSocket pour real-time data streaming"""
    await websocket.accept()
    data_service = DataService(db=None)
    
    try:
        while True:
            # Envoie données toutes les 10 secondes
            metrics = await data_service.get_location_metrics(location_id)
            
            data = {
                "timestamp": datetime.utcnow().isoformat(),
                "discharge_m3_s": metrics.current_discharge,
                "water_level_m": metrics.water_level,
                "water_status": metrics.water_status,
                "alert_level": metrics.alert_level,
                "temperature_c": metrics.temperature,
                "rainfall_24h": metrics.rainfall_24h,
            }
            
            await websocket.send_json(data)
            await asyncio.sleep(10)
    
    except Exception as e:
        print(f"WebSocket error: {e}")
        await websocket.close()


# ==================== EXPERT API ====================

@app.post("/expert/query", tags=["Expert"])
async def expert_query(
    query_type: str,
    basin_id: str,
    parameters: Dict[str, Any]
):
    """Requête d'analyse personnalisée pour experts"""
    return {
        "query_id": f"query_{datetime.utcnow().timestamp()}",
        "query_type": query_type,
        "basin_id": basin_id,
        "status": "processing",
        "estimated_wait_seconds": 30
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
