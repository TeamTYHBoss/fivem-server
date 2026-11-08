CREATE TABLE IF NOT EXISTS whellco_report_teleports (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    staff_citizenid VARCHAR(50) NOT NULL,
    report_id INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX staff_idx (staff_citizenid),
    INDEX report_idx (report_id),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;