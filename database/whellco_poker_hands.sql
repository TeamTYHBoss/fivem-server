CREATE TABLE IF NOT EXISTS whellco_poker_hands (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    player_citizenid VARCHAR(50) NOT NULL,
    bet INT UNSIGNED NOT NULL,
    player_hand VARCHAR(50) NOT NULL,
    dealer_hand VARCHAR(50) NOT NULL,
    result VARCHAR(20) NOT NULL,
    payout INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX player_idx (player_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;