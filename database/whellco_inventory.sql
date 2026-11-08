CREATE TABLE IF NOT EXISTS whellco_inventory_storages (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    storage_type VARCHAR(32) NOT NULL,
    identifier VARCHAR(64) NOT NULL,
    items LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY storage_unique (storage_type, identifier),
    INDEX storage_type_idx (storage_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;