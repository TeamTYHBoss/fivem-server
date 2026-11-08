-- Converts auction export seller and buyer ownership to QBCore citizen IDs.
-- Run once after installing QBCore.

ALTER TABLE whellco_auction_exports
    MODIFY seller_id VARCHAR(64) NOT NULL,
    MODIFY buyer_id VARCHAR(64) NULL;

UPDATE whellco_auction_exports
JOIN players
    ON whellco_auction_exports.seller_id = players.license
SET whellco_auction_exports.seller_id = players.citizenid;

UPDATE whellco_auction_exports
JOIN players
    ON whellco_auction_exports.buyer_id = players.license
SET whellco_auction_exports.buyer_id = players.citizenid;