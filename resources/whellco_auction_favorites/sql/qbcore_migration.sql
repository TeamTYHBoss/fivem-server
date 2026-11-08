-- Converts auction favorites ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_favorites
    MODIFY character_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_favorites
JOIN players
    ON whellco_auction_favorites.character_id = players.license
SET whellco_auction_favorites.character_id = players.citizenid;