-- Phase 6 migration: link economy records to individual characters.

ALTER TABLE whellco_players
    ADD COLUMN character_id INT UNSIGNED NULL AFTER identifier,
    ADD UNIQUE KEY uq_whellco_players_character (character_id);

ALTER TABLE whellco_transactions
    ADD COLUMN character_id INT UNSIGNED NULL AFTER identifier,
    ADD INDEX idx_whellco_transactions_character (character_id);

ALTER TABLE whellco_inventory
    DROP PRIMARY KEY,
    ADD COLUMN character_id INT UNSIGNED NULL AFTER identifier,
    ADD PRIMARY KEY (character_id, item_id),
    ADD INDEX idx_whellco_inventory_character (character_id);
