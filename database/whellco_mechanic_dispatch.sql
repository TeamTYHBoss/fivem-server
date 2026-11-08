CREATE TABLE IF NOT EXISTS whellco_mechanic_dispatch (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    requester_citizenid VARCHAR(50) NOT NULL,
    mechanic_citizenid VARCHAR(50) NULL,
    repair_type VARCHAR(32) NOT NULL,
    price BIGINT NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    reason VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    INDEX requester_idx (requester_citizenid),
    INDEX mechanic_idx (mechanic_citizenid),
    INDEX status_idx (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;