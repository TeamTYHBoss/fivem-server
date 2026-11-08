CREATE TABLE IF NOT EXISTS whellco_vehicle_tax_records (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT UNSIGNED NOT NULL,
    owner_id INT UNSIGNED NOT NULL,
    tax_amount INT NOT NULL,
    paid_until DATETIME NOT NULL,
    paid_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_whellco_vehicle_tax_records (vehicle_id)
);

CREATE TABLE IF NOT EXISTS whellco_vehicle_tax_penalties (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT UNSIGNED NOT NULL,
    owner_id INT UNSIGNED NOT NULL,
    penalty_amount INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
