-- Converts existing WhellCo character identifiers to QBCore citizen IDs.
-- Run once after installing QBCore and before starting the migrated resources.

UPDATE whellco_characters
JOIN players
    ON whellco_characters.identifier = players.license
SET whellco_characters.identifier = players.citizenid;

UPDATE whellco_players
JOIN players
    ON whellco_players.identifier = players.license
SET whellco_players.identifier = players.citizenid;
