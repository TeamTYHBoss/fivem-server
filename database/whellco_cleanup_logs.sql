CREATE TABLE IF NOT EXISTS whellco_cleanup_logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    admin_citizenid VARCHAR(50) NOT NULL,
    vehicles_cleaned INT UNSIGNED NOT NULL DEFAULT 0,
    peds_cleaned INT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX admin_idx (admin_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;