CREATE TABLE IF NOT EXISTS whellco_gang_territories (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    territory_id VARCHAR(64) NOT NULL,
    owner_gang VARCHAR(64) NOT NULL DEFAULT 'unclaimed',
    captured_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY territory_unique (territory_id),
    INDEX owner_gang_idx (owner_gang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;