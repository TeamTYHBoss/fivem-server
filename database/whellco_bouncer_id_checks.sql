CREATE TABLE IF NOT EXISTS whellco_bouncer_id_checks (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    guard_citizenid VARCHAR(50) NOT NULL,
    target_citizenid VARCHAR(50) NOT NULL,
    has_valid_id TINYINT(1) NOT NULL DEFAULT 0,
    has_fake_id TINYINT(1) NOT NULL DEFAULT 0,
    allowed TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX guard_idx (guard_citizenid),
    INDEX target_idx (target_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;