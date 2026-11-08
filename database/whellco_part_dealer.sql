CREATE TABLE IF NOT EXISTS whellco_part_dealer_sales (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    part_type VARCHAR(32) NOT NULL,
    amount INT NOT NULL,
    payout BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX part_idx (part_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;