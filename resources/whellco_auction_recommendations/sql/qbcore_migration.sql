-- Converts auction recommendation ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_recommendations
    MODIFY character_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_recommendations
JOIN players
    ON whellco_auction_recommendations.character_id = players.license
SET whellco_auction_recommendations.character_id = players.citizenid;