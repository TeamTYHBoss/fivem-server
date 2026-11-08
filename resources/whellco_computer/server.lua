-- This update adds server-side marketplace metadata validation and recovery tools.
-- Existing computer server logic remains unchanged except for the marketplace listing
-- creation path and the new admin recovery commands.

-- Add near the top of the existing server.lua:
local RecoveryStates = {
    PENDING = 'pending',
    RECOVERY = 'recovery'
}

-- Add this helper before marketplace event handlers:
local function getVerifiedItemMetadata(Player, itemName)
    local item = Player.Functions.GetItemByName(itemName)

    if not item then
        return nil
    end

    -- Only preserve metadata that is present on the server-side inventory item.
    -- Client-supplied metadata is never trusted.
    return item.metadata or {}
end

-- Replace the client-supplied metadata assignment in the marketplace listing handler with:
-- local metadata = getVerifiedItemMetadata(Player, itemName) or {}

-- Add these admin commands near the bottom of the existing server.lua:
QBCore.Commands.Add('computerrecovery', 'List unresolved computer recovery records', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    MySQL.query(
        [[SELECT id, type, status, citizenid, created_at
          FROM whellco_computer_state
          WHERE status = ?
          ORDER BY id DESC
          LIMIT 50]],
        { RecoveryStates.RECOVERY },
        function(records)
            if not records or #records == 0 then
                TriggerClientEvent('QBCore:Notify', source, 'No unresolved recovery records.', 'primary', 5000)
                return
            end

            for _, record in ipairs(records) do
                TriggerClientEvent(
                    'QBCore:Notify',
                    source,
                    ('Recovery #%s: %s (%s)'):format(record.id, record.type or 'unknown', record.citizenid or 'unknown'),
                    'error',
                    10000
                )
            end
        end
    )
end, 'admin')

QBCore.Commands.Add('computerresolve', 'Resolve a computer recovery record', {{ name = 'id', help = 'Recovery record ID' }}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local recordId = tonumber(args[1])

    if not Player or not recordId then
        return
    end

    MySQL.update(
        'UPDATE whellco_computer_state SET status = ? WHERE id = ? AND status = ?',
        { 'resolved', recordId, RecoveryStates.RECOVERY },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                TriggerClientEvent('QBCore:Notify', source, ('Resolved recovery record #%s.'):format(recordId), 'success', 5000)
            else
                TriggerClientEvent('QBCore:Notify', source, 'Recovery record not found or already resolved.', 'error', 5000)
            end
        end
    )
end, 'admin')