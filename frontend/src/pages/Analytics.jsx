import React, { useState, useEffect } from 'react';
import { BarChart3, TrendingUp, TrendingDown, Users, Zap } from 'lucide-react';

/**
 * Page Analytique
 * Analyses avancées, statistiques, tendances historiques
 */
export default function Analytics() {
  const [stats, setStats] = useState(null);
  const [ecosystems, setEcosystems] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      fetch('/api/dashboard/statistics').then(r => r.json()),
      fetch('/api/ecosystem/services').then(r => r.json())
    ]).then(([st, eco]) => {
      setStats(st);
      setEcosystems(eco);
      setLoading(false);
    }).catch(err => {
      console.error('Analytics load error:', err);
      setLoading(false);
    });
  }, []);

  if (loading) return <div className="p-4">Chargement analytique...</div>;

  return (
    <div className="analytics-page p-6">
      <h1 className="text-3xl font-bold mb-6">📊 Analytique Avancée</h1>

      {/* Résumé Économique */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-bold text-sm text-gray-700">Popultion Bassin</h3>
              <Users className="text-blue-600" size={20} />
            </div>
            <p className="text-3xl font-bold text-blue-600">
              {(stats.basin_summary?.total_population / 1e6)?.toFixed(1)}M
            </p>
            <p className="text-xs text-gray-600 mt-2">habitants</p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-bold text-sm text-gray-700">Zone Irrigation</h3>
              <TrendingUp className="text-green-600" size={20} />
            </div>
            <p className="text-3xl font-bold text-green-600">
              {(stats.basin_summary?.total_irrigation_km2 / 1000)?.toFixed(0)}K
            </p>
            <p className="text-xs text-gray-600 mt-2">km² exploités</p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-bold text-sm text-gray-700">Production Énérgie</h3>
              <Zap className="text-yellow-600" size={20} />
            </div>
            <p className="text-3xl font-bold text-yellow-600">
              {stats.economic?.expected_energy_production_gwh}
            </p>
            <p className="text-xs text-gray-600 mt-2">GWh/an</p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-bold text-sm text-gray-700">Pop. Agricole</h3>
              <TrendingDown className="text-amber-600" size={20} />
            </div>
            <p className="text-3xl font-bold text-amber-600">
              {(stats.economic?.irrigation_area_served_km2 / 1000)?.toFixed(0)}K
            </p>
            <p className="text-xs text-gray-600 mt-2">dans agriculture</p>
          </div>
        </div>
      )}

      {/* Hydrologie */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-bold mb-4 flex items-center">
            <BarChart3 className="mr-2 text-blue-600" size={20} />
            État Hydrologique
          </h3>
          <div className="space-y-4">
            <div>
              <p className="text-sm text-gray-700 mb-1">Débit Moyen</p>
              <p className="text-2xl font-bold text-blue-600">{stats?.hydrological?.avg_discharge_m3_s}</p>
              <p className="text-xs text-gray-600">m³/s</p>
            </div>
            <div>
              <p className="text-sm text-gray-700 mb-1">Stockage Total (Barrages)</p>
              <p className="text-2xl font-bold text-blue-600">
                {(stats?.hydrological?.total_water_stored_m3 / 1e9)?.toFixed(1)}
              </p>
              <p className="text-xs text-gray-600">milliards m³</p>
            </div>
            <div>
              <p className="text-sm text-gray-700 mb-1">Taux de Remplissage</p>
              <div className="w-full bg-gray-200 rounded h-3 mt-1">
                <div
                  className="bg-blue-500 h-3 rounded"
                  style={{ width: `${stats?.hydrological?.storage_percent}%` }}
                ></div>
              </div>
              <p className="text-xs text-gray-600 mt-1">{stats?.hydrological?.storage_percent}%</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-bold mb-4">🎯 KPIs Système</h3>
          <div className="space-y-3 text-sm">
            <div className="flex justify-between items-center p-2 bg-gray-50 rounded">
              <span className="font-medium">Alertes (24h)</span>
              <span className="badge badge-warning">{stats?.alerts_24h || 0}</span>
            </div>
            <div className="flex justify-between items-center p-2 bg-gray-50 rounded">
              <span className="font-medium">Confiance Modèles</span>
              <span className="text-green-600 font-bold">
                {(stats?.forecast_confidence_avg * 100)?.toFixed(0)}%
              </span>
            </div>
            <div className="flex justify-between items-center p-2 bg-gray-50 rounded">
              <span className="font-medium">Couverture Sensors</span>
              <span className="text-blue-600 font-bold">95%</span>
            </div>
            <div className="flex justify-between items-center p-2 bg-gray-50 rounded">
              <span className="font-medium">Uptime API</span>
              <span className="text-green-600 font-bold">99.97%</span>
            </div>
          </div>
        </div>
      </div>

      {/* Services Écosystémiques */}
      <div className="bg-white rounded-lg shadow p-6 mb-8">
        <h3 className="text-lg font-bold mb-4">🌍 Services Écosystémiques Valorisés</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {ecosystems.map((service, idx) => (
            <div key={idx} className="border rounded p-4">
              <h4 className="font-bold mb-2 capitalize">{service.service_type.replace('_', ' ')}</h4>
              <div className="space-y-2 text-sm">
                <p>
                  <strong>Valeur:</strong> €{(service.annual_value_eur / 1e6)?.toFixed(0)}M/an
                </p>
                {service.tonnes_co2_equivalent && (
                  <p>
                    <strong>CO₂:</strong> {(service.tonnes_co2_equivalent / 1e6)?.toFixed(1)}M tonnes/an
                  </p>
                )}
                <p>
                  <strong>Surface:</strong> {(service.affected_area_km2 / 1000)?.toFixed(0)}K km²
                </p>
                <p>
                  <strong>Biodiversité:</strong> {(service.biodiversity_index * 100)?.toFixed(0)}/100
                </p>
                <p>
                  <strong>Tendance:</strong> <span className="badge badge-success">{service.trend}</span>
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Tendances Historiques */}
      <div className="bg-gradient-to-r from-purple-50 to-pink-50 rounded-lg shadow p-6">
        <h3 className="text-lg font-bold mb-4">📈 Tendances 2020-2025</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
          <div className="bg-white rounded p-4">
            <p className="font-bold mb-2">Débit Moyen</p>
            <p className="text-2xl font-bold text-blue-600">+12%</p>
            <p className="text-xs text-gray-600">vs 2015-2020</p>
          </div>
          <div className="bg-white rounded p-4">
            <p className="font-bold mb-2">Variabilité</p>
            <p className="text-2xl font-bold text-orange-600">+35%</p>
            <p className="text-xs text-gray-600">extrêmes plus fréquents</p>
          </div>
          <div className="bg-white rounded p-4">
            <p className="font-bold mb-2">Température</p>
            <p className="text-2xl font-bold text-red-600">+1.2°C</p>
            <p className="text-xs text-gray-600">réchauffement local</p>
          </div>
        </div>
      </div>
    </div>
  );
}
