import React, { useState } from 'react';
import { Sprout, TrendingUp, AlertCircle } from 'lucide-react';

/**
 * Page Recommandations Agricoles
 * Basées sur prévisions hydrologiques + climat
 */
export default function Agriculture() {
  const [farmerId, setFarmerId] = useState('farmer_001');
  const [recommendations, setRecommendations] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleFetchRecommendations = () => {
    setLoading(true);
    fetch(`/api/agriculture/recommendations/${farmerId}`)
      .then(r => r.json())
      .then(data => {
        setRecommendations(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Recommendations load error:', err);
        setLoading(false);
      });
  };

  return (
    <div className="agriculture-page p-6">
      <h1 className="text-3xl font-bold mb-6">🌾 Recommandations Agricoles</h1>

      {/* Sélecteur Agriculteur */}
      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <h3 className="text-lg font-bold mb-4">Consulter un Agriculteur</h3>
        <div className="flex gap-3">
          <input
            type="text"
            placeholder="ID ou No. Agriculteur"
            value={farmerId}
            onChange={(e) => setFarmerId(e.target.value)}
            className="form-control flex-1"
          />
          <button
            onClick={handleFetchRecommendations}
            className="btn btn-primary"
            disabled={loading}
          >
            {loading ? 'Chargement...' : 'Consulter'}
          </button>
        </div>
      </div>

      {/* Recommandations */}
      {recommendations && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* Planning */}
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <Sprout className="mr-2 text-green-600" size={20} />
              Planning Cultural
            </h3>
            <div className="space-y-4">
              <div>
                <p className="text-sm font-medium text-gray-700">Type Culture</p>
                <p className="text-2xl font-bold capitalize">{recommendations.crop_type}</p>
              </div>

              <div>
                <p className="text-sm font-medium text-gray-700">📅 Date Semis Recommandée</p>
                <p className="text-xl font-bold text-blue-600">
                  {new Date(recommendations.recommended_sowing_date).toLocaleDateString('fr-FR', {
                    day: 'numeric',
                    month: 'long',
                    year: 'numeric'
                  })}
                </p>
              </div>

              <div>
                <p className="text-sm font-medium text-gray-700">Variété Recommandée</p>
                <p className="text-lg font-bold text-green-600">
                  {recommendations.recommended_variety?.replace('_', ' ').toUpperCase()}
                </p>
              </div>

              <div className="p-4 bg-green-50 rounded border border-green-200">
                <p className="text-sm font-bold mb-2">✅ Conseil du jour</p>
                <p className="text-sm text-green-900">
                  Basé sur prévisions hydrologiques et données satellite, cette date offre 
                  maximisation du potentiel hydrique et rendement accru de {(recommendations.expected_yield_increase * 100)?.toFixed(0)}%.
                </p>
              </div>
            </div>
          </div>

          {/* Hydrologie */}
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <TrendingUp className="mr-2 text-blue-600" size={20} />
              Conditions Hydrologiques
            </h3>
            <div className="space-y-4">
              <div>
                <p className="text-sm font-medium text-gray-700">Pluie Prévue (Saison Croissance)</p>
                <p className="text-3xl font-bold text-blue-600">{recommendations.expected_rainfall_mm?.toFixed(0)}</p>
                <p className="text-xs text-gray-500">mm</p>
              </div>

              <div>
                <p className="text-sm font-medium text-gray-700">Rendement Attendu</p>
                <div className="flex items-center gap-2">
                  <span className="text-2xl font-bold text-green-600">
                    +{(recommendations.expected_yield_increase * 100)?.toFixed(0)}%
                  </span>
                  <span className="text-sm text-gray-600">vs année précédente</span>
                </div>
              </div>

              <div>
                <p className="text-sm font-medium text-gray-700">Confiance Prévision</p>
                <div className="w-full bg-gray-200 rounded h-3 mt-1">
                  <div
                    className="bg-green-500 h-3 rounded"
                    style={{ width: `${recommendations.confidence * 100}%` }}
                  ></div>
                </div>
                <p className="text-xs text-gray-600 mt-1">{(recommendations.confidence * 100)?.toFixed(0)}%</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Calendrier Irrigation */}
      {recommendations?.irrigation_schedule && (
        <div className="bg-white rounded-lg shadow p-6 mb-8">
          <h3 className="text-lg font-bold mb-4">💧 Calendrier d'Irrigation</h3>
          <p className="text-sm text-gray-600 mb-4">
            Chaque mois, l'apport hydrique recommandé (% du besoin total).
          </p>
          <div className="grid grid-cols-3 md:grid-cols-6 gap-3">
            {Object.entries(recommendations.irrigation_schedule).map(([month, percent]) => (
              <div key={month} className="bg-blue-50 rounded p-4 text-center">
                <p className="text-xs font-bold uppercase text-gray-700 mb-2">{month}</p>
                <p className="text-2xl font-bold text-blue-600">{percent}</p>
                <p className="text-xs text-gray-500">%</p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Alertes Agricoles */}
      <div className="bg-yellow-50 border border-yellow-200 rounded p-6 mb-8">
        <h3 className="text-lg font-bold mb-4 flex items-center">
          <AlertCircle className="mr-2 text-yellow-600" size={20} />
          ⚠️ Alertes Agricoles Importantes
        </h3>
        <ul className="space-y-2 text-sm">
          <li>✅ <strong>Pas d'alerte sécheresse</strong> prévue pour cette saison</li>
          <li>✅ <strong>Humidité des sols</strong> sera optimale pour croissance</li>
          <li>⚠️ <strong>Vigilance crues</strong> en août-septembre: suivre alertes système</li>
          <li>💡 <strong>Opportunité d'irrigation:</strong> réduire consommation d'eau de 35% avec prévisions</li>
        </ul>
      </div>

      {/* Actions Recommandées */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-green-50 border border-green-200 rounded p-6">
          <h4 className="font-bold mb-3">✅ À Faire MAINTENANT</h4>
          <ul className="space-y-2 text-sm">
            <li>🌱 Préparer semences variété recommandée</li>
            <li>🚜 Vérifier/réparer équipement irrigation</li>
            <li>📅 Marquer date semis dans calendrier</li>
            <li>💰 S'inscrire assurance indicielle (si disponible)</li>
          </ul>
        </div>

        <div className="bg-blue-50 border border-blue-200 rounded p-6">
          <h4 className="font-bold mb-3">ℹ️ À Savoir</h4>
          <ul className="space-y-2 text-sm">
            <li>📱 Recevez alertes jour J-3 avant semis optimal</li>
            <li>📊 Suivi réel via satellite (NDVI gratuit)</li>
            <li>👨‍🌾 Conseils personnalisés via appli mobile</li>
            <li>💬 Support multilingue (français, wolof, pulaar)</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
