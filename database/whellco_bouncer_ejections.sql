CREATE TABLE IF NOT EXISTS whellco_bouncer_ejections (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    guard_citizenid VARCHAR(50) NOT NULL,
    target_citizenid VARCHAR(50) NOT NULL,
    reason VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX guard_idx (guard_citizenid),
    INDEX target_idx (target_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;