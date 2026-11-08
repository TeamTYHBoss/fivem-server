-- Converts vehicle registration ownership records to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_registrations
JOIN players
    ON whellco_registrations.character_id = players.license
SET whellco_registrations.character_id = players.citizenid;