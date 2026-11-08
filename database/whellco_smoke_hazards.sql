CREATE TABLE IF NOT EXISTS whellco_smoke_hazards (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    reporter_citizenid VARCHAR(50) NOT NULL,
    detector_label VARCHAR(100) NOT NULL,
    coords_x FLOAT NOT NULL,
    coords_y FLOAT NOT NULL,
    coords_z FLOAT NOT NULL,
    message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX reporter_idx (reporter_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;