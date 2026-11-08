CREATE TABLE IF NOT EXISTS whellco_robbery_logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    robber_citizenid VARCHAR(50) NOT NULL,
    victim_citizenid VARCHAR(50) NOT NULL,
    cash_stolen INT UNSIGNED NOT NULL DEFAULT 0,
    items_stolen JSON NULL,
    success TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX robber_idx (robber_citizenid),
    INDEX victim_idx (victim_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;