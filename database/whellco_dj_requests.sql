CREATE TABLE IF NOT EXISTS whellco_dj_requests (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patron_citizenid VARCHAR(50) NOT NULL,
    song_id INT UNSIGNED NOT NULL,
    song_label VARCHAR(100) NOT NULL,
    price INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX patron_idx (patron_citizenid),
    INDEX song_idx (song_id),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;