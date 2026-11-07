CREATE TABLE IF NOT EXISTS whellco_vehicles (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    character_id INT UNSIGNED NOT NULL,
    model VARCHAR(64) NOT NULL,
    plate VARCHAR(8) NOT NULL,
    stored TINYINT(1) NOT NULL DEFAULT 1,
    garage VARCHAR(64) NOT NULL DEFAULT 'legion_garage',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_whellco_vehicles_character (character_id),
    UNIQUE KEY uq_whellco_vehicles_plate (plate)
);
