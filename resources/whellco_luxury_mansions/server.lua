local QBCore = exports['qb-core']:GetCoreObject()

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function getMansion(id)
    for _, mansion in ipairs(Config.Mansions) do
        if mansion.id == id then
            return mansion
        end
    end

    return nil
end

RegisterNetEvent('whellco_luxury_mansions:purchase', function(mansionId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion then
        return
    end

    local owned = MySQL.scalar.await(
        'SELECT COUNT(*) FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    if owned and owned > 0 then
        TriggerClientEvent('QBCore:Notify', source, 'This mansion is already owned.', 'error')
        return
    end

    if Player.PlayerData.money.bank < mansion.price then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money in your bank account.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', mansion.price, 'mansion-purchase')

    MySQL.insert.await(
        [[INSERT INTO whellco_mansion_ownership
            (mansion_id, owner_citizenid, purchase_price)
          VALUES (?, ?, ?)]],
        {
            mansion.id,
            Player.PlayerData.citizenid,
            mansion.price
        }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for $%d.'):format(mansion.label, mansion.price), 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:enter', function(mansionId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion then
        return
    end

    local ownership = MySQL.single.await(
        'SELECT owner_citizenid FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    if not ownership then
        TriggerClientEvent('QBCore:Notify', source, 'This mansion is not owned.', 'error')
        return
    end

    if ownership.owner_citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this mansion.', 'error')
        return
    end

    TriggerClientEvent('whellco_luxury_mansions:enter', source, mansion)
end)

RegisterNetEvent('whellco_luxury_mansions:customise', function(mansionId, setting, value)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion then
        return
    end

    local ownership = MySQL.single.await(
        'SELECT owner_citizenid FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    if not ownership or ownership.owner_citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this mansion.', 'error')
        return
    end

    if setting ~= 'wall_colour' and setting ~= 'floor_style' and setting ~= 'lighting_mode' then
        return
    end

    MySQL.update.await(
        ('UPDATE whellco_mansion_ownership SET %s = ? WHERE mansion_id = ?'):format(setting),
        {
            value,
            mansion.id
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Mansion customisation updated.', 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:sellback', function(mansionId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion then
        return
    end

    local ownership = MySQL.single.await(
        'SELECT owner_citizenid, purchase_price FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    if not ownership then
        TriggerClientEvent('QBCore:Notify', source, 'This mansion is not owned.', 'error')
        return
    end

    if ownership.owner_citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this mansion.', 'error')
        return
    end

    local sellbackAmount = math.floor(mansion.price * (mansion.sellbackPercent / 100))

    MySQL.query.await(
        'DELETE FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    Player.Functions.AddMoney('bank', sellbackAmount, 'mansion-sellback')

    TriggerClientEvent('QBCore:Notify', source, ('Sold %s back to the state for $%d.'):format(mansion.label, sellbackAmount), 'success')
end)

RegisterCommand('mansions', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_luxury_mansions:openMenu', source)
end, false)

RegisterCommand('mansionadmin', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Luxury mansion system is active.', 'primary')
end, false)