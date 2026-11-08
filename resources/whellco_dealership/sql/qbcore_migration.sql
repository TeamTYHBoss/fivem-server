-- Converts dealership ownership and purchase records to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_dealership_purchases
JOIN players
    ON whellco_dealership_purchases.character_id = players.license
SET whellco_dealership_purchases.character_id = players.citizenid;