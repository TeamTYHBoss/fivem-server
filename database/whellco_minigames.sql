CREATE TABLE IF NOT EXISTS whellco_minigames (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    player_citizenid VARCHAR(50) NOT NULL,
    game_type VARCHAR(50) NOT NULL,
    score INT UNSIGNED NOT NULL,
    success TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX player_idx (player_citizenid),
    INDEX game_idx (game_type),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;