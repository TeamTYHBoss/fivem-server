CREATE TABLE IF NOT EXISTS whellco_insurance_fraud_cases (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    claim_id INT UNSIGNED NOT NULL,
    citizenid VARCHAR(50) NULL,
    officer_citizenid VARCHAR(50) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'open',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_by VARCHAR(50) NULL,
    resolved_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    INDEX claim_idx (claim_id),
    INDEX citizen_idx (citizenid),
    INDEX status_idx (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;