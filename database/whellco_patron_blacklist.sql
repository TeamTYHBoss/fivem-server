CREATE TABLE IF NOT EXISTS whellco_patron_blacklist (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    added_by VARCHAR(50) NOT NULL,
    reason VARCHAR(255) NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX active_idx (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;