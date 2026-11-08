-- Converts existing housing ownership and key records to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_properties
JOIN players
    ON whellco_properties.owner_character_id = players.license
SET whellco_properties.owner_character_id = players.citizenid;

UPDATE whellco_property_keys
JOIN players
    ON whellco_property_keys.character_id = players.license
SET whellco_property_keys.character_id = players.citizenid;