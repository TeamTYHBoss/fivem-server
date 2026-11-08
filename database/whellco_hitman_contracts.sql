CREATE TABLE IF NOT EXISTS whellco_hitman_contracts (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    hitman_citizenid VARCHAR(50) NOT NULL,
    tier INT UNSIGNED NOT NULL,
    payout INT UNSIGNED NOT NULL,
    success TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX hitman_idx (hitman_citizenid),
    INDEX tier_idx (tier),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;