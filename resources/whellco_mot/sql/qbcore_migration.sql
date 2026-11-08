-- Converts vehicle MOT ownership records to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_mot_records
JOIN players
    ON whellco_mot_records.character_id = players.license
SET whellco_mot_records.character_id = players.citizenid;