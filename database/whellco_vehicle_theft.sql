CREATE TABLE IF NOT EXISTS whellco_vehicle_theft_events (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    thief_citizenid VARCHAR(50) NOT NULL,
    plate VARCHAR(16) NOT NULL,
    model VARCHAR(64) NOT NULL,
    coords LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX thief_idx (thief_citizenid),
    INDEX plate_idx (plate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;