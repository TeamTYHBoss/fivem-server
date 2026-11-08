CREATE TABLE IF NOT EXISTS whellco_dance_scores (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patron_citizenid VARCHAR(50) NOT NULL,
    score INT UNSIGNED NOT NULL,
    success TINYINT(1) NOT NULL DEFAULT 0,
    reward INT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX patron_idx (patron_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;