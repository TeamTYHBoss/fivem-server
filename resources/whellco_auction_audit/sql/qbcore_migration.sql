-- Converts auction audit ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_audit
    MODIFY actor_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_audit
JOIN players
    ON whellco_auction_audit.actor_id = players.license
SET whellco_auction_audit.actor_id = players.citizenid;