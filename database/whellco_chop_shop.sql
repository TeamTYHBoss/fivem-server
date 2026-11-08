CREATE TABLE IF NOT EXISTS whellco_stolen_vehicles (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    plate VARCHAR(16) NOT NULL,
    model VARCHAR(64) NOT NULL,
    owner_citizenid VARCHAR(50) NULL,
    thief_citizenid VARCHAR(50) NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'stolen',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    recovered_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    INDEX plate_idx (plate),
    INDEX status_idx (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS whellco_chop_shop_sales (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    plate VARCHAR(16) NOT NULL,
    parts VARCHAR(255) NOT NULL,
    payout BIGINT NOT NULL,
    stolen TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX plate_idx (plate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;