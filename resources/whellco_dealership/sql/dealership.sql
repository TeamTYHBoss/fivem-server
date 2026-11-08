CREATE TABLE IF NOT EXISTS whellco_vehicles (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    owner_id INT UNSIGNED NOT NULL,
    model VARCHAR(64) NOT NULL,
    plate VARCHAR(16) NOT NULL UNIQUE,
    primary_color INT NOT NULL DEFAULT 0,
    secondary_color INT NOT NULL DEFAULT 0,
    pearl_color INT NOT NULL DEFAULT 0,
    wheel_color INT NOT NULL DEFAULT 0,
    engine_level INT NOT NULL DEFAULT 0,
    brakes_level INT NOT NULL DEFAULT 0,
    transmission_level INT NOT NULL DEFAULT 0,
    armor_level INT NOT NULL DEFAULT 0,
    turbo TINYINT(1) NOT NULL DEFAULT 0,
    stored TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS whellco_vehicle_customization_history (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT UNSIGNED NOT NULL,
    customization_type VARCHAR(64) NOT NULL,
    price INT NOT NULL,
    customized_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
