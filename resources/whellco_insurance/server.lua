local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_insurance:purchasePolicy', function(policyId)
    local source = source
    local Player = getQbPlayer(source)
    local policy = Config.Policies[policyId]

    if not Player or not policy then
        return
    end

    if not Player.Functions.RemoveMoney('bank', policy.price, ('Purchased %s insurance'):format(policy.label)) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_insurance_policies
                (character_id, policy_id, price)
            VALUES (?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, policyId, policy.price }
    )

    TriggerClientEvent('QBCore:Notify', source, ('%s insurance purchased.'):format(policy.label), 'success')
end)