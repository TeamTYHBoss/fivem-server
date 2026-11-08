CREATE TABLE IF NOT EXISTS whellco_insurance_policies (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    character_id INT UNSIGNED NOT NULL,
    vehicle_id INT UNSIGNED NOT NULL,
    plan VARCHAR(32) NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_whellco_insurance_policies (vehicle_id)
);

CREATE TABLE IF NOT EXISTS whellco_insurance_claims (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    policy_id INT UNSIGNED NOT NULL,
    vehicle_id INT UNSIGNED NOT NULL,
    damage_amount INT NOT NULL,
    payout INT NOT NULL,
    status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS whellco_insurance_repairs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT UNSIGNED NOT NULL,
    repair_cost INT NOT NULL,
    insurance_covered INT NOT NULL DEFAULT 0,
    repaired_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
