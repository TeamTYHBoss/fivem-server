-- Converts auction search ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_search
    MODIFY character_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_search
JOIN players
    ON whellco_auction_search.character_id = players.license
SET whellco_auction_search.character_id = players.citizenid;