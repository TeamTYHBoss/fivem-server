CREATE TABLE IF NOT EXISTS whellco_weapon_accessories (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    weapon_name VARCHAR(64) NOT NULL,
    accessories LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY weapon_unique (citizenid, weapon_name),
    INDEX citizenid_idx (citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;