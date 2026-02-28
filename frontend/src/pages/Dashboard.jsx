import React, { useState, useEffect } from 'react';
import { Alert, Gauge, Droplet, Wind, Leaf, Zap, TrendingDown, TrendingUp } from 'lucide-react';

/**
 * Page Dashboard - Vue d'ensemble principal
 * KPIs temps réel, alertes, état des barrages, statistiques
 */
export default function Dashboard() {
  const [dashboardData, setDashboardData] = useState(null);
  const [mapData, setMapData] = useState(null);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeAlerts, setActiveAlerts] = useState([]);

  useEffect(() => {
    // Charge toutes les données dashboard
    Promise.all([
      fetch('/api/dashboard/overview').then(r => r.json()),
      fetch('/api/dashboard/map-data').then(r => r.json()),
      fetch('/api/dashboard/statistics').then(r => r.json()),
      fetch('/api/alerts').then(r => r.json())
    ]).then(([overview, maps, statistics, alerts]) => {
      setDashboardData(overview);
      setMapData(maps);
      setStats(statistics);
      setActiveAlerts(alerts);
      setLoading(false);
    }).catch(err => {
      console.error('Dashboard load error:', err);
      setLoading(false);
    });

    // Rafraîchit toutes les 30 secondes
    const interval = setInterval(() => {
      fetch('/api/dashboard/overview')
        .then(r => r.json())
        .then(data => setDashboardData(data));
    }, 30000);

    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return <div className="dashboard-loading">Chargement données...</div>;
  }

  return (
    <div className="dashboard-container p-4 md:p-6">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-gray-900 mb-2">
          🌊 AQUAMIND - Bassin Fleuve Sénégal
        </h1>
        <p className="text-gray-600">
          Système Intelligent de Prédiction Hydrologique - {new Date().toLocaleDateString('fr-FR')}
        </p>
      </div>

      {/* Alertes Actives */}
      {activeAlerts.length > 0 && (
        <div className="alerts-section mb-6">
          <div className="alert alert-warning" role="alert">
            <Alert className="alert-icon" size={20} />
            <div className="alert-content">
              <h4 className="font-bold">Alertes Actives ({activeAlerts.length})</h4>
              {activeAlerts.map((alert, idx) => (
                <p key={idx} className="text-sm mt-1">
                  ⚠️ <strong>{alert.alert_type.toUpperCase()}</strong> à {alert.location} 
                  (confiance: {(alert.confidence * 100).toFixed(0)}%)
                </p>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* KPIs Principaux */}
      <div className="kpis-grid grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {/* Débit Bakel */}
        <div className="kpi-card bg-white rounded-lg shadow p-4">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-semibold text-gray-700">Bakel</h3>
            <Droplet className="text-blue-500" size={20} />
          </div>
          <div className="text-3xl font-bold text-blue-600">
            {dashboardData?.general_status?.bakel?.discharge_m3_s?.toFixed(0) || '—'} m³/s
          </div>
          <p className="text-xs mt-2">
            <span className={`badge ${
              dashboardData?.general_status?.bakel?.alert_level === 'normal' 
                ? 'badge-success' 
                : 'badge-warning'
            }`}>
              {dashboardData?.general_status?.bakel?.water_status || '—'}
            </span>
          </p>
        </div>

        {/* Débit Matam */}
        <div className="kpi-card bg-white rounded-lg shadow p-4">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-semibold text-gray-700">Matam</h3>
            <Droplet className="text-blue-500" size={20} />
          </div>
          <div className="text-3xl font-bold text-blue-600">
            {dashboardData?.general_status?.matam?.discharge_m3_s?.toFixed(0) || '—'} m³/s
          </div>
          <p className="text-xs mt-2">
            <span className={`badge ${
              dashboardData?.general_status?.matam?.alert_level === 'normal' 
                ? 'badge-success' 
                : 'badge-warning'
            }`}>
              {dashboardData?.general_status?.matam?.water_status || '—'}
            </span>
          </p>
        </div>

        {/* Manantali */}
        <div className="kpi-card bg-white rounded-lg shadow p-4">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-semibold text-gray-700">Manantali</h3>
            <Zap className="text-yellow-500" size={20} />
          </div>
          <div className="text-3xl font-bold">
            <span className="text-amber-600">{dashboardData?.dams?.manantali?.level_percent || '—'}%</span>
          </div>
          <p className="text-xs mt-2 text-gray-600">
            Capacité: 11.3 Mrd m³
          </p>
        </div>

        {/* Énergie Potentielle */}
        <div className="kpi-card bg-white rounded-lg shadow p-4">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-semibold text-gray-700">Production Énergie</h3>
            <Zap className="text-green-500" size={20} />
          </div>
          <div className="text-3xl font-bold text-green-600">
            {stats?.economic?.expected_energy_production_gwh || '—'} GWh
          </div>
          <p className="text-xs mt-2 text-gray-600">
            Capacité: 280 MW
          </p>
        </div>
      </div>

      {/* Système & Bassin */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        {/* État Système */}
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-bold mb-4 flex items-center">
            <span className="w-3 h-3 rounded-full bg-green-500 mr-2"></span>
            État du Système
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">Base de Données</span>
              <span className="badge badge-success">Operational</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">Modèles IA</span>
              <span className="badge badge-success">Opérationnel</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">Capteurs IoT</span>
              <span className="text-sm font-semibold">
                {dashboardData?.statistics?.sensors_operational || '—'}/{dashboardData?.statistics?.sensors_total || '—'}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">Confiance Modèles</span>
              <span className="text-sm font-semibold text-blue-600">
                {(dashboardData?.statistics?.forecast_confidence_avg * 100)?.toFixed(0) || '—'}%
              </span>
            </div>
          </div>
        </div>

        {/* Résumé Bassin */}
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-bold mb-4 flex items-center">
            <Leaf className="mr-2 text-green-600" size={20} />
            Bassin Sénégal - Résumé
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">Population</span>
              <span className="text-sm font-semibold">15 millions</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">Surface</span>
              <span className="text-sm font-semibold">300,000 km²</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">Irrigation</span>
              <span className="text-sm font-semibold">220,000 km²</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">Stockage Eau (Barrages)</span>
              <span className="text-sm font-semibold">{stats?.hydrological?.total_water_stored_m3 ? 
                (stats.hydrological.total_water_stored_m3 / 1e9).toFixed(1) : '—'} Mrd m³
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Prévisions Rapides */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Prévision Court Terme */}
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-bold mb-4">Prévision Court Terme</h3>
          <div className="space-y-2 text-sm">
            <p>📊 <strong>LSTM</strong> - Débits 7-15 jours</p>
            <p>✅ Confiance: <strong>88%</strong></p>
            <p>⏰ Horizon: <strong>10 jours</strong></p>
            <div className="mt-3 p-2 bg-blue-50 rounded">
              <p className="text-xs text-blue-900">Pro. tendance à la hausse légère</p>
            </div>
          </div>
        </div>

        {/* Alerte Inondation */}
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-bold mb-4">Risque Inondation</h3>
          <div className="space-y-2 text-sm">
            <p>🗺️ <strong>ConvLSTM</strong> - Prédiction spatiale</p>
            <p>⚠️ Matam: <strong>Vigilance</strong> (J+10)</p>
            <p>👥 Pop. à risque: <strong>~15,000</strong></p>
            <div className="mt-3 p-2 bg-yellow-50 rounded">
              <p className="text-xs text-yellow-900">Alerte précoce activée</p>
            </div>
          </div>
        </div>

        {/* Sécheresse */}
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-bold mb-4">Prévision Sécheresse</h3>
          <div className="space-y-2 text-sm">
            <p>🌧️ <strong>Transformer</strong> - Saisonnalité 3-6m</p>
            <p>📈 Tendance: <strong>Normale</strong></p>
            <p>Probabilité: 60% normal, 20%+ débit</p>
            <div className="mt-3 p-2 bg-green-50 rounded">
              <p className="text-xs text-green-900">Réserves suffisantes prévues</p>
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="mt-8 pt-4 border-t border-gray-200 text-xs text-gray-500">
        <p>AQUAMIND v1.0 | Dernière mise à jour: {dashboardData?.timestamp}</p>
      </div>
    </div>
  );
}
