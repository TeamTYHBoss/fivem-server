local QBCore = exports['qb-core']:GetCoreObject()

local penaltyCooldowns = {}

RegisterNetEvent('whellco_lockpick_penalties:apply', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (penaltyCooldowns[source] or 0) < Config.PenaltyCooldownSeconds then
        return
    end

    penaltyCooldowns[source] = now

    if math.random(1, 100) > Config.BreakChance then
        TriggerClientEvent('QBCore:Notify', source, 'Lockpick survived.', 'primary')
        return
    end

    local broken = math.random(Config.MinLockpicksBroken, Config.MaxLockpicksBroken)
    local removed = 0

    for _, itemName in ipairs(Config.PenaltyItems) do
        local item = Player.Functions.GetItemByName(itemName)

        if item and item.amount > 0 then
            local removeAmount = math.min(item.amount, broken - removed)

            if removeAmount > 0 then
                Player.Functions.RemoveItem(itemName, removeAmount)
                removed = removed + removeAmount
            end
        end

        if removed >= broken then
            break
        end
    end

    if removed > 0 then
        TriggerClientEvent('QBCore:Notify', source, ('%d lockpick(s) broke.'):format(removed), 'error')
    else
        TriggerClientEvent('QBCore:Notify', source, 'No lockpicks available to break.', 'error')
    end
end)

RegisterCommand('testlockpickpenalty', function()
    TriggerEvent('whellco_lockpick_penalties:apply')
end, false)