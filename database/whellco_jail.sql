CREATE TABLE IF NOT EXISTS whellco_jail_sentences (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    sentence_minutes INT NOT NULL,
    remaining_minutes INT NOT NULL,
    reason VARCHAR(180) NULL,
    facility VARCHAR(16) NOT NULL DEFAULT 'jail',
    released TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizenid_idx (citizenid),
    INDEX active_sentence_idx (citizenid, released)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;