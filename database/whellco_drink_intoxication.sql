CREATE TABLE IF NOT EXISTS whellco_drink_intoxication (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    bartender_citizenid VARCHAR(50) NOT NULL,
    patron_citizenid VARCHAR(50) NOT NULL,
    drink_score INT UNSIGNED NOT NULL,
    quality VARCHAR(20) NOT NULL,
    intoxication INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX bartender_idx (bartender_citizenid),
    INDEX patron_idx (patron_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;