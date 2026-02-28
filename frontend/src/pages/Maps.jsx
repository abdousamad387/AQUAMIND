import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Circle, Polyline } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

/**
 * Page Cartes Leaflet
 * Visualisation géographique: bassins, barrages, stations, risques
 */
export default function Maps() {
  const [mapData, setMapData] = useState(null);
  const [selectedLayer, setSelectedLayer] = useState('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard/map-data')
      .then(r => r.json())
      .then(data => {
        setMapData(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Map data load error:', err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="p-4">Chargement carte...</div>;
  if (!mapData) return <div className="p-4">Erreur chargement données</div>;

  // Coordonnées centre Sénégal
  const mapCenter = [13.5, -12.0];
  const mapZoom = 7;

  // Icône personnalisée pour barrages
  const damIcon = L.icon({
    iconUrl: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="red"><rect x="2" y="8" width="20" height="10" rx="2"/><polygon points="5,8 12,2 19,8"/></svg>',
    iconSize: [32, 32],
    iconAnchor: [16, 32],
    popupAnchor: [0, -32]
  });

  // Icône pour stations
  const stationIcon = L.icon({
    iconUrl: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="blue"><circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="5" fill="white"/></svg>',
    iconSize: [24, 24],
    iconAnchor: [12, 12],
    popupAnchor: [0, -12]
  });

  // Topologie du fleuve (connexions simplifiées)
  const riverRoute = [
    [10.5, -10.5],   // Fouta Djallon
    [12.08, -7.98],  // Manantali
    [13.2, -8.1],    // Félou
    [14.22, -11.92], // Bakel
    [14.13, -11.77], // Matam
    [13.83, -13.15], // Kaédi
    [14.72, -14.65], // Diama
    [14.8, -14.5]    // Delta
  ];

  return (
    <div className="maps-container h-screen flex flex-col">
      {/* Toolbar */}
      <div className="p-4 bg-white border-b flex justify-between items-center">
        <h2 className="text-xl font-bold">🗺️ Carte Interactive - Bassin Sénégal</h2>
        <div className="flex gap-2">
          <button 
            className={`btn ${selectedLayer === 'all' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setSelectedLayer('all')}
          >
            Vue Complète
          </button>
          <button 
            className={`btn ${selectedLayer === 'dams' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setSelectedLayer('dams')}
          >
            Barrages
          </button>
          <button 
            className={`btn ${selectedLayer === 'stations' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setSelectedLayer('stations')}
          >
            Stations
          </button>
        </div>
      </div>

      {/* Carte Leaflet */}
      <div className="flex-1">
        <MapContainer
          center={mapCenter}
          zoom={mapZoom}
          style={{ height: '100%', width: '100%' }}
        >
          {/* Tile Layer OpenStreetMap */}
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution='&copy; OpenStreetMap contributors'
          />

          {/* Topologie du Fleuve */}
          {(selectedLayer === 'all') && (
            <Polyline
              positions={riverRoute}
              color="blue"
              weight={3}
              opacity={0.7}
              dashArray="5, 5"
            />
          )}

          {/* Barrages */}
          {(selectedLayer === 'all' || selectedLayer === 'dams') && mapData.dams.map(dam => (
            <Marker
              key={dam.id}
              position={[dam.coordinates.lat, dam.coordinates.lon]}
              icon={damIcon}
            >
              <Popup>
                <div className="popup-content">
                  <h4 className="font-bold">{dam.name}</h4>
                  <p><strong>Niveau:</strong> {dam.level_percent.toFixed(1)}%</p>
                  <p><strong>Débit:</strong> {dam.discharge_m3_s.toFixed(0)} m³/s</p>
                  <p><strong>Capacité:</strong> {(dam.capacity_m3 / 1e9).toFixed(1)} Mrd m³</p>
                  {dam.power_capacity_mw > 0 && (
                    <p><strong>Puissance:</strong> {dam.power_capacity_mw} MW</p>
                  )}
                </div>
              </Popup>
            </Marker>
          ))}

          {/* Stations Hydrologiques */}
          {(selectedLayer === 'all' || selectedLayer === 'stations') && 
            Object.entries(mapData.stations).map(([id, station]) => (
            <Marker
              key={id}
              position={[station.coords.lat, station.coords.lon]}
              icon={stationIcon}
            >
              <Popup>
                <div className="popup-content">
                  <h4 className="font-bold">{station.name}</h4>
                  <p><strong>Débit:</strong> {station.discharge.toFixed(0)} m³/s</p>
                  <p className="text-xs text-gray-600 mt-1">
                    ID: {id}
                  </p>
                </div>
              </Popup>
            </Marker>
          ))}

          {/* Zones de Bassin (cercles) */}
          {(selectedLayer === 'all') && mapData.basins.map(basin => (
            <Circle
              key={basin.id}
              center={[basin.coordinates.lat, basin.coordinates.lon]}
              radius={Math.sqrt(basin.area_km2) * 500}
              color="green"
              fillColor="lightgreen"
              fillOpacity={0.2}
              weight={2}
            >
              <Popup>
                <div className="popup-content">
                  <h4 className="font-bold">{basin.name}</h4>
                  <p><strong>Pays:</strong> {basin.id}</p>
                  <p><strong>Surface:</strong> {basin.area_km2.toLocaleString()} km²</p>
                  <p><strong>Population:</strong> {(basin.population / 1000000).toFixed(1)}M</p>
                </div>
              </Popup>
            </Circle>
          ))}
        </MapContainer>
      </div>

      {/* Légende */}
      <div className="p-4 bg-gray-50 border-t">
        <div className="flex gap-6 flex-wrap text-sm">
          <div className="flex items-center gap-2">
            <span className="w-6 h-6 bg-red-500 rounded"></span>
            <span>Barrage</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="w-4 h-4 bg-blue-500 rounded-full"></span>
            <span>Station Hydrométrique</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="w-4 h-4 border-2 border-green-500"></span>
            <span>Bassin Versant</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-4 h-1 bg-blue-500" style={{borderTop: '2px dashed blue'}}></div>
            <span>Topologie Fleuve</span>
          </div>
        </div>
      </div>
    </div>
  );
}
