CREATE TABLE IF NOT EXISTS whellco_hangover_recovery (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patron_citizenid VARCHAR(50) NOT NULL,
    item_name VARCHAR(50) NOT NULL,
    intoxication_before INT UNSIGNED NOT NULL,
    intoxication_after INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX patron_idx (patron_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;