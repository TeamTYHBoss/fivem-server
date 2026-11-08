CREATE TABLE IF NOT EXISTS whellco_handover_signoffs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    character_id INT UNSIGNED NOT NULL,
    section VARCHAR(64) NOT NULL,
    signed_off TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_whellco_handover_signoffs (character_id, section)
);
