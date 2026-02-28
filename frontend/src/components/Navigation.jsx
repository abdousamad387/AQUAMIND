import React, { useState } from 'react';
import { Menu, X, LogOut, Settings, BarChart3, Droplet, Zap, AlertCircle, Leaf, Home, Map, TrendingUp } from 'lucide-react';

/**
 * Composant Navigation - Barre latérale et header
 */
export default function Navigation({ sidebarOpen, setSidebarOpen, systemStatus }) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const links = [
    { href: '/', label: 'Tableau de Bord', icon: Home },
    { href: '/maps', label: 'Cartes', icon: Map },
    { href: '/forecasts', label: 'Prévisions', icon: TrendingUp },
    { href: '/optimization', label: 'Optimisation', icon: Zap },
    { href: '/alerts', label: 'Alertes', icon: AlertCircle },
    { href: '/agriculture', label: 'Agriculture', icon: Leaf },
    { href: '/analytics', label: 'Analytique', icon: BarChart3 },
  ];

  return (
    <>
      {/* Header Superior */}
      <header className="bg-white border-b sticky top-0 z-50">
        <div className="flex items-center justify-between px-4 py-3 md:px-6">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="hidden md:block p-2 hover:bg-gray-100 rounded"
            >
              {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 hover:bg-gray-100 rounded"
            >
              {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
            <div className="flex items-center gap-2">
              <Droplet className="text-blue-600" size={24} />
              <h1 className="font-bold text-lg hidden sm:block">AQUAMIND</h1>
            </div>
          </div>

          <div className="flex items-center gap-4">
            {/* Statut système */}
            <div className="hidden sm:flex items-center gap-2 text-xs">
              <span className="w-2 h-2 rounded-full bg-green-500"></span>
              <span className="text-gray-600">
                {systemStatus?.uptime_percent ? `${systemStatus.uptime_percent}% uptime` : 'Operational'}
              </span>
            </div>

            {/* User Menu */}
            <div className="flex items-center gap-3">
              <button className="p-2 hover:bg-gray-100 rounded" title="Settings">
                <Settings size={18} className="text-gray-600" />
              </button>
              <button className="p-2 hover:bg-gray-100 rounded" title="Logout">
                <LogOut size={18} className="text-gray-600" />
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <nav className="md:hidden px-4 py-2 border-t">
            {links.map(link => {
              const Icon = link.icon;
              return (
                <a
                  key={link.href}
                  href={link.href}
                  className="flex items-center gap-3 px-4 py-2 text-sm hover:bg-gray-100 rounded"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  <Icon size={18} />
                  {link.label}
                </a>
              );
            })}
          </nav>
        )}
      </header>

      {/* Sidebar */}
      <aside className={`fixed left-0 top-14 bottom-0 w-56 bg-gray-900 text-white transition-transform duration-300 hidden md:block z-40 overflow-y-auto
        ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
        <nav className="p-4 space-y-2">
          {links.map(link => {
            const Icon = link.icon;
            return (
              <a
                key={link.href}
                href={link.href}
                className="flex items-center gap-3 px-4 py-3 rounded hover:bg-gray-800 transition-colors"
              >
                <Icon size={18} />
                <span className="text-sm font-medium">{link.label}</span>
              </a>
            );
          })}
        </nav>
      </aside>
    </>
  );
}
