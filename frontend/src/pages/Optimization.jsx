import React, { useState, useEffect } from 'react';
import { Zap, Droplet, Leaf, Target } from 'lucide-react';

/**
 * Page Optimisation des Barrages
 * Recommandations multi-objectifs: énergie, irrigation, environnement, sécurité
 */
export default function Optimization() {
  const [optimization, setOptimization] = useState(null);
  const [loading, setLoading] = useState(true);
  const [scenarioMode, setScenarioMode] = useState(false);
  const [scenario, setScenario] = useState({
    manantali_discharge_m3_s: 1200,
    diama_discharge_m3_s: 950,
    felou_discharge_m3_s: 400
  });

  useEffect(() => {
    fetch('/api/optimization/dams')
      .then(r => r.json())
      .then(data => {
        setOptimization(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Optimization load error:', err);
        setLoading(false);
      });
  }, []);

  const handleScenarioSubmit = () => {
    setLoading(true);
    fetch('/api/optimization/scenario', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(scenario)
    })
      .then(r => r.json())
      .then(data => {
        alert('Scénario analysé: ' + JSON.stringify(data, null, 2));
        setLoading(false);
      })
      .catch(err => {
        console.error('Scenario error:', err);
        setLoading(false);
      });
  };

  if (loading) return <div className="p-4">Chargement optimisation...</div>;

  return (
    <div className="optimization-page p-6">
      <h1 className="text-3xl font-bold mb-6">⚙️ Optimisation Multi-Objectifs des Barrages</h1>

      {/* Stratégie Recommandée */}
      {optimization && (
        <div className="bg-gradient-to-r from-green-50 to-blue-50 rounded-lg shadow p-6 mb-8">
          <h2 className="text-2xl font-bold mb-4">📋 Stratégie Recommandée</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {/* Manantali */}
            <div className="bg-white rounded p-4">
              <h3 className="font-bold text-lg mb-3">Manantali</h3>
              <div className="space-y-2">
                <div>
                  <p className="text-xs font-medium text-gray-600">Débit Cible</p>
                  <p className="text-2xl font-bold text-blue-600">
                    {optimization.manantali_target_discharge_m3_s?.toFixed(0)}
                  </p>
                  <p className="text-xs text-gray-500">m³/s</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-600">Niveau Cible</p>
                  <p className="text-xl font-bold">{optimization.manantali_target_level_percent?.toFixed(1)}%</p>
                </div>
              </div>
            </div>

            {/* Diama */}
            <div className="bg-white rounded p-4">
              <h3 className="font-bold text-lg mb-3">Diama</h3>
              <div className="space-y-2">
                <div>
                  <p className="text-xs font-medium text-gray-600">Débit Cible</p>
                  <p className="text-2xl font-bold text-blue-600">
                    {optimization.diama_target_discharge_m3_s?.toFixed(0)}
                  </p>
                  <p className="text-xs text-gray-500">m³/s</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-600">Contrôle Salinité</p>
                  <p className="text-sm font-bold text-green-600">
                    {optimization.expected_salinity_control ? '✅ Actif' : '❌ Inactif'}
                  </p>
                </div>
              </div>
            </div>

            {/* Félou */}
            <div className="bg-white rounded p-4">
              <h3 className="font-bold text-lg mb-3">Félou</h3>
              <div className="space-y-2">
                <div>
                  <p className="text-xs font-medium text-gray-600">Débit Cible</p>
                  <p className="text-2xl font-bold text-blue-600">
                    {optimization.felu_target_discharge_m3_s?.toFixed(0)}
                  </p>
                  <p className="text-xs text-gray-500">m³/s</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-600">Niveau Cible</p>
                  <p className="text-xl font-bold">{optimization.felu_target_level_percent?.toFixed(1)}%</p>
                </div>
              </div>
            </div>

            {/* Score Global */}
            <div className="bg-gradient-to-br from-green-500 to-blue-500 text-white rounded p-4">
              <h3 className="font-bold text-lg mb-3">Score Global</h3>
              <div className="space-y-2">
                <div>
                  <p className="text-xs opacity-90">Multi-Objectifs</p>
                  <p className="text-4xl font-bold">{optimization.multi_objective_score?.toFixed(0)}</p>
                  <p className="text-xs opacity-90">/100</p>
                </div>
                <div className="mt-3 pt-3 border-t border-white border-opacity-30">
                  <p className="text-xs opacity-90">Amélioration</p>
                  <p className="text-2xl font-bold">+{(optimization.improvement_vs_manual * 100)?.toFixed(0)}%</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Impacts Prédits */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-bold">Énergie</h3>
            <Zap className="text-yellow-500" size={20} />
          </div>
          <p className="text-3xl font-bold text-yellow-600">{optimization?.expected_energy_gwh?.toFixed(1)}</p>
          <p className="text-xs text-gray-600 mt-1">GWh générés</p>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-bold">Irrigation</h3>
            <Droplet className="text-blue-500" size={20} />
          </div>
          <p className="text-3xl font-bold text-blue-600">{(optimization?.expected_irrigation_m3 / 1e6)?.toFixed(0)}</p>
          <p className="text-xs text-gray-600 mt-1">M m³ disponibles</p>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-bold">Environnement</h3>
            <Leaf className="text-green-500" size={20} />
          </div>
          <p className="text-2xl font-bold capitalize text-green-600">
            {optimization?.expected_environmental_benefit}
          </p>
          <p className="text-xs text-gray-600 mt-1">Services écosystémiques</p>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-bold">Sécurité</h3>
            <Target className="text-red-500" size={20} />
          </div>
          <p className="text-2xl font-bold text-green-600">✅ Contrôlée</p>
          <p className="text-xs text-gray-600 mt-1">Débits stables</p>
        </div>
      </div>

      {/* Analyse Scénario */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-bold mb-4">🎮 Analyseur de Scénarios</h3>
        <p className="text-sm text-gray-600 mb-4">
          Testez différentes démographies de débits et voyez impacts prédits.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
          <div>
            <label className="block text-sm font-medium mb-1">Manantali (m³/s)</label>
            <input
              type="number"
              value={scenario.manantali_discharge_m3_s}
              onChange={(e) => setScenario({ ...scenario, manantali_discharge_m3_s: e.target.value })}
              className="form-control"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Diama (m³/s)</label>
            <input
              type="number"
              value={scenario.diama_discharge_m3_s}
              onChange={(e) => setScenario({ ...scenario, diama_discharge_m3_s: e.target.value })}
              className="form-control"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Félou (m³/s)</label>
            <input
              type="number"
              value={scenario.felou_discharge_m3_s}
              onChange={(e) => setScenario({ ...scenario, felou_discharge_m3_s: e.target.value })}
              className="form-control"
            />
          </div>
        </div>

        <button
          onClick={handleScenarioSubmit}
          className="btn btn-primary"
          disabled={loading}
        >
          {loading ? 'Analyse en cours...' : 'Analyser Scénario'}
        </button>
      </div>

      {/* Recommandations */}
      <div className="mt-8 bg-blue-50 border border-blue-200 rounded p-6">
        <h3 className="text-lg font-bold mb-4">💡 Recommandations</h3>
        <ul className="space-y-2 text-sm">
          <li>✅ Augmenter débit Manantali pour maximiser production énergétique</li>
          <li>✅ Maintenir niveau Diama > 65% pour contrôle salinité</li>
          <li>✅ Prévoir crue écologique artificielle (août-septembre)</li>
          <li>✅ Coordonner avec OMVS pour règles d'exploitation partagées</li>
        </ul>
      </div>
    </div>
  );
}
