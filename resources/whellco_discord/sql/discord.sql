CREATE TABLE IF NOT EXISTS whellco_discord_links (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    character_id INT UNSIGNED NOT NULL,
    discord_id VARCHAR(32) NOT NULL,
    linked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_whellco_discord_links (character_id, discord_id)
);

CREATE TABLE IF NOT EXISTS whellco_discord_logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    log_type VARCHAR(64) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
