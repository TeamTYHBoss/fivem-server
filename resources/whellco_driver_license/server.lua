local QBCore = exports['qb-core']:GetCoreObject()

local function hasLicense(Player, licenseType)
    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_driver_licenses
            WHERE citizenid = ?
              AND license_type = ?
              AND status = 'active'
        ]],
        { Player.PlayerData.citizenid, licenseType }
    )

    return count and count > 0
end

local function issueLicense(Player, licenseType)
    MySQL.query.await(
        [[
            INSERT INTO whellco_driver_licenses
                (citizenid, license_type, status)
            VALUES (?, ?, 'active')
            ON DUPLICATE KEY UPDATE
                status = 'active',
                issued_at = CURRENT_TIMESTAMP
        ]],
        { Player.PlayerData.citizenid, licenseType }
    )
end

RegisterNetEvent('whellco_driver_license:purchase', function(licenseType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local license = Config.Licenses[licenseType]

    if not Player or not license then
        TriggerClientEvent('QBCore:Notify', source, 'License type not found.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if #(coords - Config.DMV.location) > Config.DMV.radius then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the DMV.', 'error')
        return
    end

    if hasLicense(Player, licenseType) then
        TriggerClientEvent('QBCore:Notify', source, 'You already have this license.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < license.price then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', license.price, ('DMV license purchase: %s'):format(licenseType))
    issueLicense(Player, licenseType)

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for %s%d.'):format(license.label, Config.CurrencySymbol, license.price), 'success')
end)

RegisterNetEvent('whellco_driver_license:revoke', function(targetCitizenId, licenseType, reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local job = Player.PlayerData.job

    if not job or job.name ~= 'police' then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to revoke licenses.', 'error')
        return
    end

    if not reason or reason == '' then
        TriggerClientEvent('QBCore:Notify', source, 'A revocation reason is required.', 'error')
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_driver_licenses
            SET status = 'revoked',
                revoked_reason = ?,
                revoked_at = CURRENT_TIMESTAMP
            WHERE citizenid = ?
              AND license_type = ?
        ]],
        { reason, targetCitizenId, licenseType }
    )

    TriggerClientEvent('QBCore:Notify', source, 'License revoked.', 'success')
end)

RegisterCommand('licenses', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for licenseType, license in pairs(Config.Licenses) do
        names[#names + 1] = ('%s - %s ($%d)'):format(licenseType, license.label, license.price)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)

RegisterCommand('buylicense', function(source, args)
    local licenseType = args[1]

    if not licenseType then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /buylicense [license_type]', 'error')
        return
    end

    TriggerEvent('whellco_driver_license:purchase', licenseType)
end, false)

RegisterCommand('revokelicense', function(source, args)
    local targetCitizenId = args[1]
    local licenseType = args[2]
    local reason = table.concat(args, ' ', 3)

    if not targetCitizenId or not licenseType or reason == '' then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /revokelicense [citizenid] [license_type] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_driver_license:revoke', targetCitizenId, licenseType, reason)
end, false)