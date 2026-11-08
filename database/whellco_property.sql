CREATE TABLE IF NOT EXISTS whellco_properties (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    property_id VARCHAR(64) NOT NULL,
    property_type VARCHAR(32) NOT NULL,
    owner_citizenid VARCHAR(50) NULL,
    for_sale TINYINT(1) NOT NULL DEFAULT 1,
    price BIGINT NOT NULL DEFAULT 0,
    locked TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY property_unique (property_id),
    INDEX owner_idx (owner_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS whellco_property_keys (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    property_id VARCHAR(64) NOT NULL,
    citizenid VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY property_key_unique (property_id, citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;