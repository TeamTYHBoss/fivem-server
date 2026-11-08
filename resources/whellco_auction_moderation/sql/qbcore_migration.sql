-- Converts auction moderation ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_moderation
    MODIFY moderator_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_moderation
JOIN players
    ON whellco_auction_moderation.moderator_id = players.license
SET whellco_auction_moderation.moderator_id = players.citizenid;