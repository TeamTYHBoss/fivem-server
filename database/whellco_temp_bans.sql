CREATE TABLE IF NOT EXISTS whellco_temp_bans (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_by VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX expires_idx (expires_at),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;