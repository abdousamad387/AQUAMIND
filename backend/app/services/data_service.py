"""
Service de gestion des données hydrologiques.
Agrégation données IoT, satellites, météo.
"""
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from typing import List, Dict, Optional, Tuple
import asyncio
from sqlalchemy.orm import Session

from app.schemas.hydrological import (
    SensorReading, LocationMetrics, Basin, Dam, WaterStatus, AlertLevel
)


class DataService:
    """Agrégateur de données hydrologiques multi-sources"""
    
    def __init__(self, db: Session):
        self.db = db
        # Données de bassin hardcodées (simulées)
        self.basins = self._init_basins()
        self.dams = self._init_dams()
        
    @staticmethod
    def _init_basins() -> Dict[str, Basin]:
        """Bassins du Sénégal"""
        return {
            "basin_001": Basin(
                id="basin_001",
                name="Haut Bassin Fouta Djallon",
                area_km2=15000,
                country="Guinée",
                coordinates={"lat": 10.5, "lon": -10.5},
                elevation_m=750,
                population=500000
            ),
            "basin_002": Basin(
                id="basin_002",
                name="Moyen Bassin Soudan Occidental",
                area_km2=120000,
                country="Mali",
                coordinates={"lat": 12.8, "lon": -8.2},
                elevation_m=200,
                population=2500000
            ),
            "basin_003": Basin(
                id="basin_003",
                name="Bassin Delta Sahélien",
                area_km2=40000,
                country="Sénégal/Mauritanie",
                coordinates={"lat": 14.8, "lon": -14.5},
                elevation_m=5,
                population=6000000
            )
        }
    
    @staticmethod
    def _init_dams() -> Dict[str, Dam]:
        """Trois barrages stratégiques"""
        return {
            "dam_manantali": Dam(
                id="dam_manantali",
                name="Manantali",
                basin_id="basin_002",
                capacity_m3=11.3e9,
                current_level_percent=62.0,
                coordinates={"lat": 12.08, "lon": -7.98},
                power_capacity_mw=200,
                spillway_discharge_m3_s=0.0
            ),
            "dam_diama": Dam(
                id="dam_diama",
                name="Diama",
                basin_id="basin_003",
                capacity_m3=0.6e9,
                current_level_percent=68.0,
                coordinates={"lat": 14.72, "lon": -14.65},
                power_capacity_mw=0,
                spillway_discharge_m3_s=50.0
            ),
            "dam_felou": Dam(
                id="dam_felou",
                name="Félou",
                basin_id="basin_002",
                capacity_m3=0.2e9,
                current_level_percent=71.0,
                coordinates={"lat": 13.2, "lon": -8.1},
                power_capacity_mw=8,
                spillway_discharge_m3_s=0.0
            )
        }
    
    def get_basin(self, basin_id: str) -> Optional[Basin]:
        """Récupérer un bassin"""
        return self.basins.get(basin_id)
    
    def get_all_basins(self) -> List[Basin]:
        """Tous les bassins"""
        return list(self.basins.values())
    
    def get_dam(self, dam_id: str) -> Optional[Dam]:
        """Récupérer un barrage"""
        return self.dams.get(dam_id)
    
    def get_all_dams(self) -> List[Dam]:
        """Tous les barrages"""
        return list(self.dams.values())
    
    async def get_location_metrics(
        self, 
        location_id: str,
        hours_back: int = 24
    ) -> LocationMetrics:
        """
        Métriques agrégées pour une localisation.
        Simule des données réalistes du bassin Sénégal.
        """
        # Données simulées réalistes (basées sur historique)
        now = datetime.utcnow()
        
        # Débit caractéristique par localisation (m³/s)
        discharge_base = {
            "station_001": 1250,  # Bakel (aval)
            "station_002": 950,   # Matam (moyen)
            "station_003": 550,   # Kaédi (fin moyen)
            "dam_manantali": 1200,
            "dam_diama": 800,
            "dam_felou": 450,
        }
        
        base_discharge = discharge_base.get(location_id, 800)
        
        # Variabilité saisonnière (août=pic, février=creux)
        seasonal_factor = 0.8 + 0.7 * np.sin(2 * np.pi * now.month / 12)
        
        # Bruit réaliste
        discharge = base_discharge * seasonal_factor * (0.9 + np.random.random() * 0.2)
        water_level = 35.0 + discharge / 150  # Relation approximate
        
        # Détermine l'état de l'eau
        if discharge < base_discharge * 0.5:
            water_status = WaterStatus.CRITICAL_LOW
        elif discharge < base_discharge * 0.8:
            water_status = WaterStatus.LOW
        elif discharge < base_discharge * 1.3:
            water_status = WaterStatus.NORMAL
        elif discharge < base_discharge * 1.8:
            water_status = WaterStatus.HIGH
        else:
            water_status = WaterStatus.CRITICAL_HIGH
        
        # Niveau d'alerte associé
        alert_level_map = {
            WaterStatus.CRITICAL_LOW: AlertLevel.ALERTE,
            WaterStatus.LOW: AlertLevel.VIGILANCE,
            WaterStatus.NORMAL: AlertLevel.NORMAL,
            WaterStatus.HIGH: AlertLevel.VIGILANCE,
            WaterStatus.CRITICAL_HIGH: AlertLevel.ALERTE_MAX,
        }
        alert_level = alert_level_map[water_status]
        
        # Pluie (variabilité saisonnière, en mm/24h)
        rainfall_24h = 5 + 25 * abs(np.sin(2 * np.pi * now.month / 12))
        rainfall_24h *= (0.8 + np.random.random() * 0.4)
        
        # Température (cycle annuel)
        temperature = 25 + 8 * np.cos(2 * np.pi * now.month / 12)
        temperature += 5 * np.sin(now.hour * 2 * np.pi / 24)
        
        # NDVI (indice végétation, [-1, 1], pic août)
        ndvi = -0.2 + 0.7 * abs(np.sin(2 * np.pi * now.month / 12))
        
        # Humidité des sols [0, 100]%
        soil_moisture = 30 + 50 * abs(np.sin(2 * np.pi * now.month / 12))
        soil_moisture *= (0.8 + np.random.random() * 0.4)
        soil_moisture = min(100, max(0, soil_moisture))
        
        # Confiance (93-99%)
        confidence = 0.93 + np.random.random() * 0.06
        
        # Map location_id to name
        location_names = {
            "station_001": "Bakel",
            "station_002": "Matam",
            "station_003": "Kaédi",
            "dam_manantali": "Manantali",
            "dam_diama": "Diama",
            "dam_felou": "Félou",
        }
        
        location_name = location_names.get(location_id, location_id)
        location_type = "dam" if "dam" in location_id else "station"
        
        # Coords approximées
        coords_map = {
            "station_001": {"lat": 14.22, "lon": -11.92},
            "station_002": {"lat": 14.13, "lon": -11.77},
            "station_003": {"lat": 13.83, "lon": -13.15},
            "dam_manantali": {"lat": 12.08, "lon": -7.98},
            "dam_diama": {"lat": 14.72, "lon": -14.65},
            "dam_felou": {"lat": 13.2, "lon": -8.1},
        }
        
        coordinates = coords_map.get(location_id, {"lat": 14.0, "lon": -12.0})
        
        return LocationMetrics(
            location_id=location_id,
            location_name=location_name,
            location_type=location_type,
            coordinates=coordinates,
            
            current_discharge=discharge,
            water_level=water_level,
            water_status=water_status,
            alert_level=alert_level,
            
            rainfall_24h=rainfall_24h,
            temperature=temperature,
            vegetation_ndvi=ndvi,
            soil_moisture=soil_moisture,
            
            timestamp=now,
            confidence=confidence
        )
    
    async def get_sensor_reading(self, station_id: str) -> SensorReading:
        """Lecture capteur (simule données IoT)"""
        now = datetime.utcnow()
        
        # Discharge réaliste par station
        discharge_map = {
            "station_001": 1200,  # Bakel
            "station_002": 950,   # Matam
            "station_003": 600,   # Kaédi
        }
        
        base_discharge = discharge_map.get(station_id, 800)
        discharge = base_discharge * (0.9 + np.random.random() * 0.2)
        
        water_quality = {
            "ph": 7.0 + np.random.gauss(0, 0.3),
            "conductivity_ms_cm": 300 + np.random.gauss(0, 50),
            "turbidity_ntu": 80 + np.random.gauss(0, 30),
            "dissolved_oxygen_mg_l": 7.0 + np.random.gauss(0, 0.5)
        }
        
        return SensorReading(
            id=f"reading_{station_id}_{now.timestamp()}",
            station_id=station_id,
            timestamp=now,
            discharge_m3_s=discharge,
            water_level_m=35.0 + discharge / 150,
            temperature_c=25 + np.random.gauss(0, 2),
            rainfall_mm=max(0, 5 + np.random.gauss(0, 5)),
            water_quality=water_quality
        )
    
    async def get_historical_data(
        self,
        location_id: str,
        days_back: int = 90
    ) -> pd.DataFrame:
        """
        Données historiques pour entraînement modèles.
        Simule 90 jours de données avec variabilité saisonnière.
        """
        dates = pd.date_range(end=datetime.utcnow(), periods=days_back * 24, freq='H')
        
        discharge_base = {
            "station_001": 1250,
            "station_002": 950,
            "dam_manantali": 1200,
        }.get(location_id, 1000)
        
        # Série temporelle réaliste avec tendances
        discharge_values = []
        rainfall_values = []
        temp_values = []
        ndvi_values = []
        
        for i, date in enumerate(dates):
            # Tendance saisonnière
            seasonal = discharge_base * (0.8 + 0.7 * np.sin(2 * np.pi * date.month / 12))
            
            # Tendance long terme (pas de changement pour stabilité)
            long_term = 1.0
            
            # Bruit (AR(1) pour corrélation)
            noise = np.random.gauss(0, 0.15)
            
            discharge = seasonal * long_term * (1 + noise)
            discharge = max(100, discharge)  # Min threshold
            
            discharge_values.append(discharge)
            
            # Pluie
            rain = max(0, 5 + 25 * np.sin(2 * np.pi * date.month / 12) + np.random.gauss(0, 10))
            rainfall_values.append(rain)
            
            # Température
            temp = 25 + 8 * np.cos(2 * np.pi * date.month / 12) + 5 * np.sin(date.hour * 2 * np.pi / 24) + np.random.gauss(0, 1)
            temp_values.append(temp)
            
            # NDVI
            ndvi = -0.2 + 0.7 * np.sin(2 * np.pi * date.month / 12) + np.random.gauss(0, 0.05)
            ndvi_values.append(ndvi)
        
        df = pd.DataFrame({
            'timestamp': dates,
            'discharge_m3_s': discharge_values,
            'rainfall_mm': rainfall_values,
            'temperature_c': temp_values,
            'ndvi': ndvi_values
        })
        
        return df
    
    async def get_forecast_inputs(
        self,
        location_id: str,
        lookback_days: int = 90
    ) -> Dict:
        """
        Prépare les entrées pour les modèles de prévision.
        Agrège données IoT + satellites + météo.
        """
        # Historique
        historical = await self.get_historical_data(location_id, lookback_days)
        
        # Données actuelles
        current_metrics = await self.get_location_metrics(location_id)
        
        return {
            'historical_discharge': historical['discharge_m3_s'].values[-30:],  # 30 derniers jours
            'historical_rainfall': historical['rainfall_mm'].values[-30:],
            'historical_temperature': historical['temperature_c'].values[-30:],
            'historical_ndvi': historical['ndvi'].values[-30:],
            'current_discharge': current_metrics.current_discharge,
            'current_water_level': current_metrics.water_level,
            'current_rainfall': current_metrics.rainfall_24h,
            'current_temperature': current_metrics.temperature,
            'current_ndvi': current_metrics.vegetation_ndvi,
            'current_soil_moisture': current_metrics.soil_moisture,
        }
