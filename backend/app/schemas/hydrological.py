"""
Schémas de données hydrologiques - Pydantic models.
Bassin du Fleuve Sénégal avec capteurs et prévisions.
"""
from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field
from enum import Enum


class AlertLevel(str, Enum):
    """Niveaux d'alerte hydrologique"""
    NORMAL = "normal"
    VIGILANCE = "vigilance"
    ALERTE = "alerte"
    ALERTE_MAX = "alerte_max"


class WaterStatus(str, Enum):
    """État de l'eau (élevé, normal, sec, critique)"""
    CRITICAL_LOW = "critical_low"
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    CRITICAL_HIGH = "critical_high"


class Basin(BaseModel):
    """Bassin versant du Sénégal"""
    id: str = Field(..., example="basin_001")
    name: str = Field(..., example="Haut Bassin Fouta Djallon")
    area_km2: float = Field(..., example=15000.0)
    country: str = Field(..., example="Guinée")
    coordinates: Dict[str, float] = Field(..., example={"lat": 10.5, "lon": -10.5})
    elevation_m: float = Field(..., example=750.0)
    population: int = Field(..., example=500000)


class Dam(BaseModel):
    """Barrage hydroélectrique"""
    id: str = Field(..., example="dam_manantali")
    name: str = Field(..., example="Manantali")
    basin_id: str
    capacity_m3: float = Field(..., example=11.3e9)
    current_level_percent: float = Field(..., example=65.0)
    coordinates: Dict[str, float]
    power_capacity_mw: float = Field(..., example=200.0)
    spillway_discharge_m3_s: float = Field(..., example=0.0)


class SensorReading(BaseModel):
    """Lecture d'un capteur IoT"""
    id: str = Field(..., example="sensor_001")
    station_id: str
    timestamp: datetime
    discharge_m3_s: Optional[float] = Field(None, example=1250.5)
    water_level_m: Optional[float] = Field(None, example=45.3)
    temperature_c: Optional[float] = Field(None, example=28.5)
    rainfall_mm: Optional[float] = Field(None, example=12.5)
    water_quality: Optional[Dict[str, float]] = Field(None, example={
        "ph": 7.5,
        "conductivity_ms_cm": 450.0,
        "turbidity_ntu": 120.0,
        "dissolved_oxygen_mg_l": 7.2
    })


class LocationMetrics(BaseModel):
    """Métriques pour une localisation (station, barrage, bassin)"""
    location_id: str
    location_name: str
    location_type: str = Field(..., example="station|dam|basin")
    coordinates: Dict[str, float]
    
    current_discharge: float = Field(..., description="m³/s")
    water_level: float = Field(..., description="mètres")
    water_status: WaterStatus
    alert_level: AlertLevel
    
    rainfall_24h: float = Field(..., description="mm")
    temperature: float = Field(..., description="°C")
    vegetation_ndvi: float = Field(..., description="[-1, 1]")
    soil_moisture: float = Field(..., description="[0, 100]%")
    
    timestamp: datetime
    confidence: float = Field(..., description="[0, 1]")


class ForecastShortTerm(BaseModel):
    """Prévision court terme (7-15 jours) - LSTM"""
    station_id: str
    forecast_date: datetime
    forecast_horizon_days: int = Field(..., example=10)
    
    predicted_discharge_m3_s: float
    predicted_water_level_m: float
    predicted_inundation_risk: float = Field(..., description="[0, 1]")
    predicted_alert_level: AlertLevel
    
    confidence_score: float = Field(..., description="[0, 1]", example=0.88)
    confidence_interval_low: float
    confidence_interval_high: float
    
    drivers: Dict[str, float] = Field(..., 
        description="Contribution des variables (ex: 0.6=rainfall_upper_basin, 0.25=dam_level, 0.15=soil_moisture)",
        example={"rainfall_upper_basin": 0.60, "dam_level": 0.25, "soil_moisture": 0.15}
    )


class ForecastSeasonal(BaseModel):
    """Prévision saisonnière (3-6 mois) - Transformer"""
    station_id: str
    forecast_date: datetime
    forecast_months: int = Field(..., example=3)
    
    predicted_season_type: str = Field(..., example="strong_monsoon|normal|drought")
    probability_strong_flow: float = Field(..., example=0.70)
    probability_normal_flow: float = Field(..., example=0.20)
    probability_weak_flow: float = Field(..., example=0.10)
    
    predicted_total_rainfall_mm: float
    predicted_avg_discharge_m3_s: float
    
    skill_score: float = Field(..., example=0.65)
    teleconnections: Dict[str, str] = Field(..., 
        example={"enso": "weak_la_nina", "indian_ocean": "neutral"}
    )


class FloodPrediction(BaseModel):
    """Prédiction d'inondation spatiale - ConvLSTM"""
    prediction_id: str
    forecast_date: datetime
    
    # Grille spatiale
    grid_resolution_m: int = Field(..., example=30)
    bbox: Dict[str, float] = Field(..., 
        example={"north": 14.5, "south": 13.8, "east": -9.5, "west": -10.8}
    )
    
    # Résultats
    inundation_probability_map: List[List[float]] = Field(..., 
        description="Matrice [lat, lon] avec probabilités [0, 1]"
    )
    affected_area_km2: float
    affected_population: int
    critical_zones: List[Dict[str, Any]] = Field(..., 
        example=[{
            "name": "Matam", 
            "inundation_prob": 0.92, 
            "affected_pop": 45000
        }]
    )


class DamOptimization(BaseModel):
    """Optimisation des barrages par Reinforcement Learning"""
    optimization_date: datetime
    
    # Stratégie recommandée
    manantali_target_discharge_m3_s: float
    diama_target_discharge_m3_s: float
    felu_target_discharge_m3_s: float
    
    manantali_target_level_percent: float
    diama_target_level_percent: float
    felu_target_level_percent: float
    
    # Objectifs satisfaits
    expected_energy_gwh: float
    expected_irrigation_m3: float
    expected_salinity_control: bool
    expected_environmental_benefit: str = Field(..., example="good|fair|poor")
    
    # Métriques
    multi_objective_score: float = Field(..., description="[0, 100]")
    improvement_vs_manual: float = Field(..., example=0.17, description="17% better")


class AgriculturalRecommendation(BaseModel):
    """Recommandation agricole basée sur prévisions"""
    farmer_id: str
    location: Dict[str, float]
    forecast_date: datetime
    
    crop_type: str = Field(..., example="rice|millet|peanuts")
    recommended_sowing_date: datetime
    recommended_variety: str = Field(..., example="drought_resistant|high_yield")
    
    expected_rainfall_growth_season: float = Field(..., example=650.0, description="mm")
    expected_yield_increase: float = Field(..., example=0.23, description="23% increase")
    confidence: float = Field(..., example=0.78)
    
    irrigation_needs: Dict[str, float] = Field(..., 
        example={"july": 50, "august": 80, "september": 30}
    )


class EcosystemService(BaseModel):
    """Service écosystémique valorisé"""
    service_id: str
    service_type: str = Field(..., example="carbon_sequestration|fish_reproduction|flood_mitigation")
    
    annual_value_eur: float
    tonnes_co2_equivalent: Optional[float]
    affected_area_km2: float
    biodiversity_index: float = Field(..., example=0.72)
    
    trend: str = Field(..., example="improving|stable|declining")


class Alert(BaseModel):
    """Alerte système de prédiction"""
    alert_id: str
    alert_type: str = Field(..., example="flood|drought|infrastructure|salinity")
    alert_level: AlertLevel
    
    location_id: str
    location_name: str
    
    trigger_date: datetime
    event_expected_date: datetime
    lead_time_days: int = Field(..., example=10)
    
    affected_area_km2: Optional[float]
    affected_population: Optional[int]
    
    message_en: str
    message_fr: str
    
    recommended_action: str
    action_authority: str = Field(..., example="OMVS|Government|Local")
    
    confidence: float = Field(..., example=0.92)


class DashboardMetrics(BaseModel):
    """Métriques pour le tableau de bord"""
    timestamp: datetime
    
    # Vue générale bassin
    total_basin_population: int
    total_irrigation_area_km2: float
    total_energy_capacity_mw: float
    
    # État hydro actuel
    general_alert_level: AlertLevel
    avg_water_status: WaterStatus
    
    # 10 prochains jours
    flood_risk_alerts: int
    drought_risk_alerts: int
    salinity_alerts: int
    
    # Impact économique
    expected_agricultural_loss_eur: float
    expected_energy_gain_eur: float
    ecosystem_value_eur: float
    
    # Couverture système
    sensors_operational: int
    sensors_total: int
    satellite_images_available_24h: int
    models_confidence_avg: float


class SystemStatus(BaseModel):
    """État du système AQUAMIND"""
    status: str = Field(..., example="operational|degraded|maintenance")
    uptime_percent: float = Field(..., example=99.97)
    last_data_update: datetime
    next_forecast_batch: datetime
    
    backend_status: str = Field(..., example="healthy|warning|error")
    database_status: str = Field(..., example="healthy|warning|error")
    ai_models_status: str = Field(..., example="healthy|warning|error")
    
    active_users: int
    total_alerts_24h: int
    model_predictions_24h: int


class ExpertQuery(BaseModel):
    """Requête d'analyse expert"""
    query_id: str
    query_type: str = Field(..., example="custom_forecast|impact_assessment|scenario_analysis")
    basin_id: str
    time_range: Dict[str, datetime]
    
    parameters: Dict[str, Any] = Field(..., 
        description="Paramètres spécifiques à la requête"
    )
    
    created_at: datetime
    priority: str = Field(..., example="low|normal|high")
