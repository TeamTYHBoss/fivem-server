CREATE TABLE IF NOT EXISTS whellco_phones (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    character_id INT UNSIGNED NOT NULL,
    phone_number VARCHAR(16) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_whellco_phones_character (character_id),
    UNIQUE KEY uq_whellco_phones_number (phone_number)
);

CREATE TABLE IF NOT EXISTS whellco_contacts (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    owner_character_id INT UNSIGNED NOT NULL,
    contact_character_id INT UNSIGNED NOT NULL,
    name VARCHAR(64) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_whellco_contacts (owner_character_id, contact_character_id)
);

CREATE TABLE IF NOT EXISTS whellco_messages (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    sender_character_id INT UNSIGNED NOT NULL,
    receiver_character_id INT UNSIGNED NOT NULL,
    message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_whellco_messages_sender (sender_character_id),
    INDEX idx_whellco_messages_receiver (receiver_character_id)
);

CREATE TABLE IF NOT EXISTS whellco_calls (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    caller_character_id INT UNSIGNED NOT NULL,
    receiver_character_id INT UNSIGNED NOT NULL,
    status ENUM('ringing', 'accepted', 'declined', 'ended') NOT NULL DEFAULT 'ringing',
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL
);
