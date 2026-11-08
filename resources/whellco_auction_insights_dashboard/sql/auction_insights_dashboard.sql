CREATE TABLE IF NOT EXISTS whellco_auction_insights_dashboard (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    auction_id INT UNSIGNED NOT NULL,
    category VARCHAR(16) NOT NULL,
    metric VARCHAR(32) NOT NULL,
    value DECIMAL(14, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY auction_category_metric (auction_id, category, metric)
);
