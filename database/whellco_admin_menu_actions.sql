CREATE TABLE IF NOT EXISTS whellco_admin_menu_actions (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    admin_citizenid VARCHAR(50) NOT NULL,
    target_citizenid VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    details JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX admin_idx (admin_citizenid),
    INDEX target_idx (target_citizenid),
    INDEX action_idx (action),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;