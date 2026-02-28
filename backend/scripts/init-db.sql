-- AQUAMIND Database Initialization Script
-- PostgreSQL + TimescaleDB

-- Create extension for time-series data
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS uuid-ossp;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hydrological data (time-series)
CREATE TABLE IF NOT EXISTS hydrological_data (
    time TIMESTAMP NOT NULL,
    location_id VARCHAR(50) NOT NULL,
    discharge_m3_s FLOAT,
    water_level_m FLOAT,
    temperature_c FLOAT,
    rainfall_mm FLOAT,
    ndvi FLOAT,
    soil_moisture FLOAT,
    PRIMARY KEY (time, location_id)
);

-- Create hypertable for time-series optimization
SELECT create_hypertable(
    'hydrological_data',
    'time',
    if_not_exists => TRUE
);

-- Forecasts table
CREATE TABLE IF NOT EXISTS forecasts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    forecast_date TIMESTAMP NOT NULL,
    location_id VARCHAR(50) NOT NULL,
    forecast_type VARCHAR(50) NOT NULL,
    horizon_days INT,
    predicted_value FLOAT,
    confidence FLOAT,
    model_used VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (forecast_date, location_id)
);

-- Alerts table
CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_type VARCHAR(50) NOT NULL,
    location_id VARCHAR(50) NOT NULL,
    alert_level VARCHAR(20) NOT NULL,
    trigger_date TIMESTAMP NOT NULL,
    event_expected_date TIMESTAMP,
    lead_time_days INT,
    affected_population INT,
    confidence FLOAT,
    message_en TEXT,
    message_fr TEXT,
    status VARCHAR(20) DEFAULT 'active',
    acknowledged_by UUID REFERENCES users(id),
    acknowledged_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (alert_type, trigger_date, location_id)
);

-- Subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    location_id VARCHAR(50) NOT NULL,
    alert_types JSON NOT NULL,
    notification_method VARCHAR(50) NOT NULL,
    notification_address VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, location_id, notification_address)
);

-- Audit log
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(255) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    changes JSON,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (user_id, created_at, resource_type)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_hydrological_location_time 
    ON hydrological_data (location_id, time DESC)
    INCLUDE (discharge_m3_s, water_level_m);

CREATE INDEX IF NOT EXISTS idx_forecasts_location_type 
    ON forecasts (location_id, forecast_type, forecast_date DESC);

CREATE INDEX IF NOT EXISTS idx_alerts_location_type 
    ON alerts (location_id, alert_type, trigger_date DESC);

-- Grant permissions
GRANT SELECT ON ALL TABLES IN SCHEMA public TO aquamind;
GRANT INSERT, UPDATE ON hydrological_data, forecasts, alerts TO aquamind;
GRANT ALL ON users, subscriptions, audit_log TO aquamind;

-- Initialize some data
INSERT INTO users (username, email, password_hash, role, country) VALUES
    ('admin', 'admin@aquamind.example.com', 'hashed_password', 'admin', 'Sénégal'),
    ('manager_senegal', 'manager@senegal.aquamind.example.com', 'hashed_password', 'manager', 'Sénégal'),
    ('manager_mauritanie', 'manager@mauritanie.aquamind.example.com', 'hashed_password', 'manager', 'Mauritanie'),
    ('manager_mali', 'manager@mali.aquamind.example.com', 'hashed_password', 'manager', 'Mali'),
    ('manager_guinee', 'manager@guinee.aquamind.example.com', 'hashed_password', 'manager', 'Guinée')
ON CONFLICT DO NOTHING;
