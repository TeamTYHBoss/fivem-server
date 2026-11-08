CREATE TABLE IF NOT EXISTS whellco_anti_lag_events (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    player_citizenid VARCHAR(50) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    score INT UNSIGNED NOT NULL,
    details JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX player_idx (player_citizenid),
    INDEX event_idx (event_type),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;