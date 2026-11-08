-- Converts auction insight ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_insights
    MODIFY character_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_insights
JOIN players
    ON whellco_auction_insights.character_id = players.license
SET whellco_auction_insights.character_id = players.citizenid;