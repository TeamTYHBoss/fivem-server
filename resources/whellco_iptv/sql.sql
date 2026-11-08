CREATE TABLE IF NOT EXISTS whellco_iptv_last_channel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL,
    tv_id VARCHAR(50) NOT NULL,
    channel INT NOT NULL DEFAULT 1,
    UNIQUE KEY unique_tv_channel (citizenid, tv_id)
);