CREATE TABLE IF NOT EXISTS whellco_staff_noclip_logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    staff_citizenid VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX staff_idx (staff_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;