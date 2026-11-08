-- Converts existing bank account ownership to QBCore citizen IDs.
-- Run once after installing QBCore and after the character migration SQL.

UPDATE whellco_bank_accounts
JOIN players
    ON whellco_bank_accounts.character_id = players.license
SET whellco_bank_accounts.character_id = players.citizenid;