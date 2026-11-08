CREATE TABLE IF NOT EXISTS whellco_blackmarket_transactions (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    transaction_type VARCHAR(32) NOT NULL,
    item_name VARCHAR(64) NULL,
    amount BIGINT NOT NULL,
    fee BIGINT NOT NULL DEFAULT 0,
    details VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizenid_idx (citizenid),
    INDEX transaction_type_idx (transaction_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;