CREATE TABLE IF NOT EXISTS whellco_traffic_fines (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    officer_citizenid VARCHAR(50) NOT NULL,
    fine_type VARCHAR(32) NOT NULL,
    amount BIGINT NOT NULL,
    points INT NOT NULL DEFAULT 0,
    reason VARCHAR(255) NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'unpaid',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX officer_idx (officer_citizenid),
    INDEX status_idx (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;