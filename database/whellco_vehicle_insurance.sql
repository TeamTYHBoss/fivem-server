CREATE TABLE IF NOT EXISTS whellco_vehicle_insurance (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    policy_type VARCHAR(32) NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX policy_idx (policy_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS whellco_insurance_claims (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    plate VARCHAR(16) NOT NULL,
    policy_type VARCHAR(32) NOT NULL,
    damage_amount BIGINT NOT NULL,
    deductible BIGINT NOT NULL,
    payout BIGINT NOT NULL,
    description VARCHAR(255) NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX plate_idx (plate),
    INDEX status_idx (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;