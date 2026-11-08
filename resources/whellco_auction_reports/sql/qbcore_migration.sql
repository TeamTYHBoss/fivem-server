-- Converts auction report ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_reports
    MODIFY reporter_id VARCHAR(64) NOT NULL;

UPDATE whellco_auction_reports
JOIN players
    ON whellco_auction_reports.reporter_id = players.license
SET whellco_auction_reports.reporter_id = players.citizenid;