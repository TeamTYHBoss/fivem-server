CREATE TABLE IF NOT EXISTS whellco_impound_records (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    plate VARCHAR(16) NOT NULL,
    owner_citizenid VARCHAR(50) NOT NULL,
    officer_citizenid VARCHAR(50) NOT NULL,
    reason VARCHAR(255) NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'impounded',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    INDEX plate_idx (plate),
    INDEX owner_idx (owner_citizenid),
    INDEX status_idx (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;