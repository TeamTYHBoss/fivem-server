CREATE TABLE IF NOT EXISTS whellco_disguise_entries (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    player_citizenid VARCHAR(50) NOT NULL,
    area_name VARCHAR(100) NOT NULL,
    disguise_type VARCHAR(50) NOT NULL,
    detected TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX player_idx (player_citizenid),
    INDEX area_idx (area_name),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;