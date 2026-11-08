-- Converts auction category ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_categories
    MODIFY character_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_categories
JOIN players
    ON whellco_auction_categories.character_id = players.license
SET whellco_auction_categories.character_id = players.citizenid;