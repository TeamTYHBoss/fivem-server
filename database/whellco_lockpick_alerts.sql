CREATE TABLE IF NOT EXISTS whellco_lockpick_alerts (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    suspect_citizenid VARCHAR(50) NOT NULL,
    lockpick_type VARCHAR(32) NOT NULL,
    coords LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX suspect_idx (suspect_citizenid),
    INDEX lockpick_idx (lockpick_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;