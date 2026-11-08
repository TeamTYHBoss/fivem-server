-- Converts auction archive seller and buyer ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_archive
    MODIFY seller_id VARCHAR(64) NOT NULL,
    MODIFY buyer_id VARCHAR(64) NULL;

UPDATE whellco_auction_archive
JOIN players
    ON whellco_auction_archive.seller_id = players.license
SET whellco_auction_archive.seller_id = players.citizenid;

UPDATE whellco_auction_archive
JOIN players
    ON whellco_auction_archive.buyer_id = players.license
SET whellco_auction_archive.buyer_id = players.citizenid;