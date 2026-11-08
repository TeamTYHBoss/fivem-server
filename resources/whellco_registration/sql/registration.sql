CREATE TABLE IF NOT EXISTS whellco_vehicle_registrations (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT UNSIGNED NOT NULL,
    owner_id INT UNSIGNED NOT NULL,
    plate VARCHAR(16) NOT NULL,
    registered TINYINT(1) NOT NULL DEFAULT 0,
    registered_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_whellco_vehicle_registrations (vehicle_id)
);

CREATE TABLE IF NOT EXISTS whellco_vehicle_transfers (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT UNSIGNED NOT NULL,
    from_owner_id INT UNSIGNED NOT NULL,
    to_owner_id INT UNSIGNED NOT NULL,
    transfer_fee INT NOT NULL,
    transferred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
