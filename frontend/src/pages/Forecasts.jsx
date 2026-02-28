import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { TrendingUp, TrendingDown, Zap } from 'lucide-react';

/**
 * Page Prévisions
 * Affiche les 5 modèles IA : LSTM, Transformer, ConvLSTM, GNN, RL
 */
export default function Forecasts() {
  const { locationId } = useParams();
  const [location, setLocation] = useState(locationId || 'station_001');
  const [shortTerm, setShortTerm] = useState(null);
  const [seasonal, setSeasonal] = useState(null);
  const [flood, setFlood] = useState(null);
  const [ensemble, setEnsemble] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    
    Promise.all([
      fetch(`/api/forecast/${location}/short-term`).then(r => r.json()),
      fetch(`/api/forecast/${location}/seasonal`).then(r => r.json()),
      fetch(`/api/forecast/${location}/flood`).then(r => r.json()),
      fetch(`/api/forecast/${location}/ensemble`).then(r => r.json())
    ]).then(([st, seas, fl, ens]) => {
      setShortTerm(st);
      setSeasonal(seas);
      setFlood(fl);
      setEnsemble(ens);
      setLoading(false);
    }).catch(err => {
      console.error('Forecast load error:', err);
      setLoading(false);
    });
  }, [location]);

  const locations = [
    { id: 'station_001', name: 'Bakel' },
    { id: 'station_002', name: 'Matam' },
    { id: 'station_003', name: 'Kaédi' },
    { id: 'dam_manantali', name: 'Manantali' },
  ];

  if (loading) return <div className="p-4">Chargement prévisions...</div>;

  return (
    <div className="forecasts-page p-6">
      <h1 className="text-3xl font-bold mb-6">📊 Prévisions Hydrologiques</h1>

      {/* Sélecteur Localisation */}
      <div className="mb-6">
        <label className="block text-sm font-bold mb-2">Sélectionner localisation:</label>
        <select 
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          className="form-control"
        >
          {locations.map(loc => (
            <option key={loc.id} value={loc.id}>{loc.name}</option>
          ))}
        </select>
      </div>

      {/* Prévisions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        {/* Court Terme (LSTM) */}
        {shortTerm && (
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <TrendingUp className="mr-2 text-blue-600" size={20} />
              Court Terme (LSTM)
            </h3>
            <div className="space-y-3">
              <div>
                <p className="text-sm font-medium text-gray-700">Prévision {shortTerm.forecast_horizon_days}J</p>
                <p className="text-3xl font-bold text-blue-600">
                  {shortTerm.predicted_discharge_m3_s?.toFixed(0) || '—'} m³/s
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-700">Intervalle Confiance (95%)</p>
                <p className="text-sm">
                  {shortTerm.confidence_interval_low?.toFixed(0)} — {shortTerm.confidence_interval_high?.toFixed(0)} m³/s
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-700">Confiance Modèle</p>
                <div className="w-full bg-gray-200 rounded h-2 mt-1">
                  <div 
                    className="bg-green-500 h-2 rounded"
                    style={{ width: `${(shortTerm.confidence_score || 0) * 100}%` }}
                  ></div>
                </div>
                <p className="text-xs text-gray-600 mt-1">{(shortTerm.confidence_score * 100)?.toFixed(0)}%</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-700">Niveau Alerte</p>
                <span className={`badge badge-${shortTerm.predicted_alert_level}`}>
                  {shortTerm.predicted_alert_level?.toUpperCase()}
                </span>
              </div>
              <div className="mt-4 p-3 bg-blue-50 rounded text-sm">
                <p className="font-semibold mb-2">Facteurs clés :</p>
                {shortTerm.drivers && Object.entries(shortTerm.drivers).map(([key, val]) => (
                  <p key={key} className="text-xs">
                    • {key}: <strong>{(val * 100).toFixed(0)}%</strong>
                  </p>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Saisonnier (Transformer) */}
        {seasonal && (
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <TrendingUp className="mr-2 text-purple-600" size={20} />
              Saisonnière (Transformer)
            </h3>
            <div className="space-y-3">
              <div>
                <p className="text-sm font-medium text-gray-700">Type Saison Prévue</p>
                <p className="text-2xl font-bold text-purple-600">
                  {seasonal.predicted_season_type?.toUpperCase().replace('_', ' ')}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-700">Débit Moyen</p>
                <p className="text-xl font-bold">{seasonal.predicted_avg_discharge_m3_s?.toFixed(0)} m³/s</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-700">Probabilités</p>
                <div className="space-y-1 text-sm">
                  <p>🟢 Fort flux: <strong>{(seasonal.probability_strong_flow * 100)?.toFixed(0)}%</strong></p>
                  <p>🟡 Flux normal: <strong>{(seasonal.probability_normal_flow * 100)?.toFixed(0)}%</strong></p>
                  <p>🔴 Flux faible: <strong>{(seasonal.probability_weak_flow * 100)?.toFixed(0)}%</strong></p>
                </div>
              </div>
              <div className="mt-4 p-3 bg-purple-50 rounded text-sm">
                <p><strong>Skill Score:</strong> {seasonal.skill_score}</p>
                <p className="text-xs text-gray-600 mt-2">Pluie prévue: {seasonal.predicted_total_rainfall_mm?.toFixed(0)} mm</p>
              </div>
            </div>
          </div>
        )}

        {/* Inondations (ConvLSTM) */}
        {flood && (
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <TrendingDown className="mr-2 text-red-600" size={20} />
              Inondations (ConvLSTM)
            </h3>
            <div className="space-y-3">
              <div>
                <p className="text-sm font-medium text-gray-700">Surface Inondable</p>
                <p className="text-2xl font-bold text-red-600">{flood.affected_area_km2?.toFixed(0)} km²</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-700">Population à Risque</p>
                <p className="text-xl font-bold">{(flood.affected_population || 0).toLocaleString()} hab</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-700">Résolution Spatiale</p>
                <p className="text-sm">{flood.grid_resolution_m}m x {flood.grid_resolution_m}m</p>
              </div>
              {flood.critical_zones?.length > 0 && (
                <div className="mt-4 p-3 bg-red-50 rounded text-sm">
                  <p className="font-semibold mb-2">Zones Critiques:</p>
                  {flood.critical_zones.map((zone, idx) => (
                    <p key={idx} className="text-xs">
                      • <strong>{zone.name}:</strong> {(zone.inundation_prob * 100)?.toFixed(0)}% probabilité
                    </p>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Optimisation Barrages (RL) */}
        {ensemble?.dam_optimization && (
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <Zap className="mr-2 text-green-600" size={20} />
              Optimisation Barrages (RL)
            </h3>
            <div className="space-y-3">
              <div>
                <p className="text-sm font-medium text-gray-700">Score Multi-Objectifs</p>
                <p className="text-3xl font-bold text-green-600">
                  {ensemble.dam_optimization.multi_objective_score?.toFixed(1)}/100
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-700">Amélioration vs Manuel</p>
                <p className="text-lg font-bold text-green-500">
                  +{(ensemble.dam_optimization.improvement_vs_manual * 100)?.toFixed(0)}%
                </p>
              </div>
              <div className="text-sm space-y-1">
                <p>⚡ Énergie attendue: {ensemble.dam_optimization.expected_energy_gwh?.toFixed(1)} GWh</p>
                <p>💧 Irrigation: {(ensemble.dam_optimization.expected_irrigation_m3 / 1e6)?.toFixed(0)}M m³</p>
                <p>📊 Environnement: <strong>{ensemble.dam_optimization.expected_environmental_benefit}</strong></p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Modèles Utilisés */}
      <div className="bg-blue-50 border border-blue-200 rounded p-6">
        <h3 className="text-lg font-bold mb-4">🤖 Architecture Ensemble (5 Modèles)</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 text-sm">
          <div className="bg-white p-3 rounded">
            <p className="font-bold">LSTM</p>
            <p className="text-xs text-gray-600">Court terme (7-15j)</p>
            <p className="text-xs mt-1">NSE: 0.88</p>
          </div>
          <div className="bg-white p-3 rounded">
            <p className="font-bold">Transformers</p>
            <p className="text-xs text-gray-600">Saisonnier (3-6m)</p>
            <p className="text-xs mt-1">Skill: 0.65</p>
          </div>
          <div className="bg-white p-3 rounded">
            <p className="font-bold">ConvLSTM</p>
            <p className="text-xs text-gray-600">Inondations (30m)</p>
            <p className="text-xs mt-1">R²: 0.92</p>
          </div>
          <div className="bg-white p-3 rounded">
            <p className="font-bold">Graph NN</p>
            <p className="text-xs text-gray-600">Propagation crues</p>
            <p className="text-xs mt-1">Active</p>
          </div>
          <div className="bg-white p-3 rounded">
            <p className="font-bold">RL Optimizer</p>
            <p className="text-xs text-gray-600">Barrages (+17%)</p>
            <p className="text-xs mt-1">Actif</p>
          </div>
        </div>
      </div>
    </div>
  );
}
