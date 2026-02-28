import React, { useState } from 'react';
import { TrendingUp, TrendingDown, AlertTriangle } from 'lucide-react';

/**
 * Page Alertes
 * Gestion des alertes hydrologiques en temps réel
 */
export default function Alerts() {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');

  React.useEffect(() => {
    fetch('/api/alerts')
      .then(r => r.json())
      .then(data => {
        setAlerts(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Alerts load error:', err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="p-4">Chargement alertes...</div>;

  const filteredAlerts = filter === 'all' 
    ? alerts 
    : alerts.filter(a => a.alert_type === filter);

  return (
    <div className="alerts-page p-6">
      <h1 className="text-3xl font-bold mb-6">⚠️ Système d'Alertes</h1>

      {/* Filtres */}
      <div className="mb-6 flex gap-2">
        {['all', 'flood', 'drought', 'salinity'].map(type => (
          <button
            key={type}
            className={`btn ${filter === type ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter(type)}
          >
            {type === 'all' ? 'Toutes' : type.toUpperCase()}
          </button>
        ))}
      </div>

      {/* Liste Alertes */}
      <div className="space-y-4">
        {filteredAlerts.length === 0 ? (
          <div className="alert alert-success">
            ✅ Pas d'alerte active
          </div>
        ) : (
          filteredAlerts.map((alert, idx) => (
            <div key={idx} className={`alert alert-${alert.alert_level} border-l-4`}>
              <div className="flex items-start gap-4">
                <AlertTriangle className="mt-1" size={24} />
                <div className="flex-1">
                  <h4 className="font-bold">
                    {alert.alert_type.toUpperCase()} - {alert.location}
                  </h4>
                  <p className="mt-1">{alert.message_fr}</p>
                  <div className="mt-2 text-sm space-y-1">
                    <p>📅 Alerte: {new Date(alert.trigger_date).toLocaleDateString('fr-FR')}</p>
                    <p>📍 Prévue: {new Date(alert.event_expected_date).toLocaleDateString('fr-FR')}</p>
                    <p>⏰ Délai: {alert.lead_time_days} jours</p>
                    <p>✅ Confiance: {(alert.confidence * 100).toFixed(0)}%</p>
                  </div>
                </div>
                <span className="badge badge-warning">{alert.alert_level}</span>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Actions Recommandées */}
      <div className="mt-8 bg-blue-50 border border-blue-200 rounded p-6">
        <h3 className="text-lg font-bold mb-4">📋 Actions Recommandées</h3>
        <div className="space-y-3 text-sm">
          <div className="flex items-start gap-3">
            <span className="badge badge-primary">1</span>
            <p>Mettre en alerte les autorités locales et services d'urgence</p>
          </div>
          <div className="flex items-start gap-3">
            <span className="badge badge-primary">2</span>
            <p>Préparer plans d'évacuation si crue > 20% seuil critique</p>
          </div>
          <div className="flex items-start gap-3">
            <span className="badge badge-primary">3</span>
            <p>Ajuster débits barrages selon recommandations AQUAMIND</p>
          </div>
          <div className="flex items-start gap-3">
            <span className="badge badge-primary">4</span>
            <p>Informer agriculteurs des changements prévus (irrigation)</p>
          </div>
        </div>
      </div>
    </div>
  );
}
