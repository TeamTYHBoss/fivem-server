-- Converts auction notification settings ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_notification_settings
    MODIFY character_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_notification_settings
JOIN players
    ON whellco_auction_notification_settings.character_id = players.license
SET whellco_auction_notification_settings.character_id = players.citizenid;