CREATE TABLE IF NOT EXISTS whellco_auction_watchlist (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    player_id VARCHAR(64) NOT NULL,
    auction_id INT UNSIGNED NOT NULL,
    plate VARCHAR(8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY player_auction_watch (player_id, auction_id)
);
