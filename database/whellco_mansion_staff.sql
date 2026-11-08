CREATE TABLE IF NOT EXISTS whellco_mansion_staff (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    mansion_id VARCHAR(100) NOT NULL,
    owner_citizenid VARCHAR(50) NOT NULL,
    staff_type VARCHAR(50) NOT NULL,
    hourly_wage INT UNSIGNED NOT NULL DEFAULT 0,
    hired_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX mansion_idx (mansion_id),
    INDEX owner_idx (owner_citizenid),
    INDEX staff_type_idx (staff_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;