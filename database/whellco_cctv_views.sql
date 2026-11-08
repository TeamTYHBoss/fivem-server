CREATE TABLE IF NOT EXISTS whellco_cctv_views (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    manager_citizenid VARCHAR(50) NOT NULL,
    camera_label VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX manager_idx (manager_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;