CREATE TABLE IF NOT EXISTS whellco_driver_licenses (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    license_type VARCHAR(32) NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'active',
    issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_reason VARCHAR(255) NULL,
    revoked_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    UNIQUE KEY citizen_license_unique (citizenid, license_type),
    INDEX citizen_idx (citizenid),
    INDEX status_idx (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;