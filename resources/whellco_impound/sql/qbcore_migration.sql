-- Converts vehicle impound ownership records to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_impound_records
JOIN players
    ON whellco_impound_records.character_id = players.license
SET whellco_impound_records.character_id = players.citizenid;