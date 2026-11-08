CREATE TABLE IF NOT EXISTS whellco_vehicle_shop_transactions (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    dealership_id VARCHAR(64) NOT NULL,
    vehicle_model VARCHAR(64) NOT NULL,
    plate VARCHAR(16) NOT NULL,
    vehicle_price BIGINT NOT NULL,
    tax BIGINT NOT NULL,
    total BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizenid_idx (citizenid),
    INDEX dealership_idx (dealership_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;