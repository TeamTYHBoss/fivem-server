CREATE TABLE IF NOT EXISTS whellco_staff_duty_sessions (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    staff_citizenid VARCHAR(50) NOT NULL,
    staff_job VARCHAR(50) NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME NULL,
    duration_seconds INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    INDEX staff_idx (staff_citizenid),
    INDEX started_idx (started_at),
    INDEX ended_idx (ended_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;