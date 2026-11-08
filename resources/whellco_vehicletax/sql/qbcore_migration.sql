-- Converts vehicle tax ownership records to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_vehicle_taxes
JOIN players
    ON whellco_vehicle_taxes.character_id = players.license
SET whellco_vehicle_taxes.character_id = players.citizenid;