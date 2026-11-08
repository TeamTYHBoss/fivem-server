CREATE TABLE IF NOT EXISTS whellco_player_reports (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    reporter_citizenid VARCHAR(50) NOT NULL,
    target_citizenid VARCHAR(50) NULL,
    report_type VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    coords_x FLOAT NOT NULL,
    coords_y FLOAT NOT NULL,
    coords_z FLOAT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'open',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX reporter_idx (reporter_citizenid),
    INDEX target_idx (target_citizenid),
    INDEX type_idx (report_type),
    INDEX status_idx (status),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;