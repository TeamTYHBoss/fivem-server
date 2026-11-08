-- Converts auction dashboard insight ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_insights_dashboard
    MODIFY character_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_insights_dashboard
JOIN players
    ON whellco_auction_insights_dashboard.character_id = players.license
SET whellco_auction_insights_dashboard.character_id = players.citizenid;