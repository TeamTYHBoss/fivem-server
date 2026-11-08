CREATE TABLE IF NOT EXISTS whellco_dancer_tips (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_citizenid VARCHAR(50) NOT NULL,
    dancer_citizenid VARCHAR(50) NOT NULL,
    amount INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX customer_idx (customer_citizenid),
    INDEX dancer_idx (dancer_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;