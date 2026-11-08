-- Converts vehicle insurance ownership records to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_insurance_policies
JOIN players
    ON whellco_insurance_policies.character_id = players.license
SET whellco_insurance_policies.character_id = players.citizenid;