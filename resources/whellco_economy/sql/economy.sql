CREATE TABLE IF NOT EXISTS whellco_players (
    identifier VARCHAR(64) NOT NULL PRIMARY KEY,
    player_name VARCHAR(64) NOT NULL,
    cash INT NOT NULL DEFAULT 500,
    bank INT NOT NULL DEFAULT 2500,
    xp INT NOT NULL DEFAULT 0,
    level INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS whellco_transactions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(64) NOT NULL,
    type ENUM('deposit', 'withdraw', 'purchase', 'wage', 'transfer', 'refund') NOT NULL,
    amount INT NOT NULL,
    balance_after INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_whellco_transactions_identifier (identifier),
    INDEX idx_whellco_transactions_created (created_at)
);

CREATE TABLE IF NOT EXISTS whellco_inventory (
    identifier VARCHAR(64) NOT NULL,
    item_id VARCHAR(64) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    PRIMARY KEY (identifier, item_id)
);
