CREATE TABLE IF NOT EXISTS whellco_bartender_mixes (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    bartender_citizenid VARCHAR(50) NOT NULL,
    drink_label VARCHAR(100) NOT NULL,
    score INT UNSIGNED NOT NULL,
    success TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX bartender_idx (bartender_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;