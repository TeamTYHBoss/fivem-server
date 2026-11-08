CREATE TABLE IF NOT EXISTS whellco_mansion_ownership (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    mansion_id VARCHAR(100) NOT NULL,
    owner_citizenid VARCHAR(50) NOT NULL,
    purchase_price INT UNSIGNED NOT NULL,
    wall_colour VARCHAR(50) DEFAULT 'ivory',
    floor_style VARCHAR(50) DEFAULT 'marble',
    lighting_mode VARCHAR(50) DEFAULT 'warm',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY mansion_unique (mansion_id),
    INDEX owner_idx (owner_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;