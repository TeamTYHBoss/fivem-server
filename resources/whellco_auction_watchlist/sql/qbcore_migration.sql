-- Converts auction watchlist ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_watchlist
    MODIFY character_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_watchlist
JOIN players
    ON whellco_auction_watchlist.character_id = players.license
SET whellco_auction_watchlist.character_id = players.citizenid;