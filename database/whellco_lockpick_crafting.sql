CREATE TABLE IF NOT EXISTS whellco_lockpick_crafting (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    recipe_id VARCHAR(32) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX recipe_idx (recipe_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;