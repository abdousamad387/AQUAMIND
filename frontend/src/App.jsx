import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';

// Pages
import Dashboard from './pages/Dashboard';
import Maps from './pages/Maps';
import Forecasts from './pages/Forecasts';
import Optimization from './pages/Optimization';
import Alerts from './pages/Alerts';
import Agriculture from './pages/Agriculture';
import Analytics from './pages/Analytics';
import Navigation from './components/Navigation';

/**
 * AQUAMIND - Application Principale
 * Système Intelligent de Prédiction Hydrologique
 */
function App() {
  const [systemStatus, setSystemStatus] = useState(null);
  const [loading, setLoading] = useState(true);
  const [sidebarOpen, setSidebarOpen] = useState(true);

  useEffect(() => {
    // Récupère statut système
    fetch('/api/system/status')
      .then(res => res.json())
      .then(data => {
        setSystemStatus(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('API Error:', err);
        setLoading(false);
      });

    // Rafraîchit toutes les 5 minutes
    const interval = setInterval(() => {
      fetch('/api/system/status')
        .then(res => res.json())
        .then(data => setSystemStatus(data));
    }, 300000);

    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
        <p>Initialisation AQUAMIND...</p>
      </div>
    );
  }

  return (
    <Router>
      <div className="app-container">
        {/* Navigation */}
        <Navigation 
          sidebarOpen={sidebarOpen}
          setSidebarOpen={setSidebarOpen}
          systemStatus={systemStatus}
        />

        {/* Contenu Principal */}
        <div className={`main-content ${sidebarOpen ? 'sidebar-open' : 'sidebar-closed'}`}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/maps" element={<Maps />} />
            <Route path="/forecasts" element={<Forecasts />} />
            <Route path="/forecasts/:locationId" element={<Forecasts />} />
            <Route path="/optimization" element={<Optimization />} />
            <Route path="/alerts" element={<Alerts />} />
            <Route path="/agriculture" element={<Agriculture />} />
            <Route path="/analytics" element={<Analytics />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
