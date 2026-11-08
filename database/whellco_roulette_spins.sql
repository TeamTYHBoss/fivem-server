CREATE TABLE IF NOT EXISTS whellco_roulette_spins (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    player_citizenid VARCHAR(50) NOT NULL,
    bet_type VARCHAR(20) NOT NULL,
    bet_value VARCHAR(20) NOT NULL,
    bet INT UNSIGNED NOT NULL,
    result_number INT UNSIGNED NOT NULL,
    result_color VARCHAR(10) NOT NULL,
    result_parity VARCHAR(10) NOT NULL,
    won TINYINT(1) NOT NULL DEFAULT 0,
    payout INT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX player_idx (player_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;