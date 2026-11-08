-- Converts vehicle ownership records to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_vehicles
JOIN players
    ON whellco_vehicles.owner_identifier = players.license
SET whellco_vehicles.owner_identifier = players.citizenid;