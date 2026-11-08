local QBCore = exports['qb-core']:GetCoreObject()

local function getUnpaidPoints(citizenid)
    local total = MySQL.scalar.await(
        [[
            SELECT COALESCE(SUM(points), 0)
            FROM whellco_traffic_fines
            WHERE citizenid = ?
              AND status = 'unpaid'
        ]],
        { citizenid }
    )

    return tonumber(total) or 0
end

local function suspendLicenses(citizenid, reason)
    for _, licenseType in ipairs(Config.SuspendedLicenseTypes) do
        MySQL.query.await(
            [[
                INSERT INTO whellco_driver_licenses
                    (citizenid, license_type, status, revoked_reason)
                VALUES (?, ?, 'suspended', ?)
                ON DUPLICATE KEY UPDATE
                    status = 'suspended',
                    revoked_reason = VALUES(revoked_reason),
                    revoked_at = CURRENT_TIMESTAMP
            ]],
            { citizenid, licenseType, reason }
        )
    end
end

local function reinstateLicenses(citizenid)
    for _, licenseType in ipairs(Config.SuspendedLicenseTypes) do
        MySQL.query.await(
            [[
                UPDATE whellco_driver_licenses
                SET status = 'active',
                    revoked_reason = NULL,
                    revoked_at = NULL
                WHERE citizenid = ?
                  AND license_type = ?
                  AND status = 'suspended'
            ]],
            { citizenid, licenseType }
        )
    end
end

RegisterNetEvent('whellco_license_suspension:check', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local points = getUnpaidPoints(Player.PlayerData.citizenid)

    if points >= Config.SuspensionPointThreshold then
        suspendLicenses(
            Player.PlayerData.citizenid,
            ('Automatic suspension: %d unpaid points reached.'):format(points)
        )

        TriggerClientEvent('QBCore:Notify', source, ('License suspended: %d unpaid point(s).'):format(points), 'error', 10000)
    else
        TriggerClientEvent('QBCore:Notify', source, ('You have %d unpaid point(s).'):format(points), 'primary')
    end
end)

RegisterNetEvent('whellco_license_suspension:reinstate', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local points = getUnpaidPoints(Player.PlayerData.citizenid)

    if points >= Config.SuspensionPointThreshold then
        TriggerClientEvent('QBCore:Notify', source, 'You must pay unpaid fines before reinstatement.', 'error')
        return
    end

    if Player.Functions.GetMoney('bank') < Config.ReinstatementFee then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money in your bank account.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', Config.ReinstatementFee, 'DMV license reinstatement')
    reinstateLicenses(Player.PlayerData.citizenid)

    TriggerClientEvent('QBCore:Notify', source, ('Licenses reinstated for %s%d.'):format(Config.CurrencySymbol, Config.ReinstatementFee), 'success')
end)

RegisterCommand('checkpoints', function()
    TriggerEvent('whellco_license_suspension:check')
end, false)

RegisterCommand('reinstate', function()
    TriggerEvent('whellco_license_suspension:reinstate')
end, false)