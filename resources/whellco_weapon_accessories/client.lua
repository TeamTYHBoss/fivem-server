local QBCore = exports['qb-core']:GetCoreObject()

local function getCurrentWeapon()
    local playerPed = PlayerPedId()
    local weapon = GetSelectedPedWeapon(playerPed)

    return weapon
end

RegisterNetEvent('whellco_weapon_accessories:apply', function(data)
    local playerPed = PlayerPedId()
    local weapon = getCurrentWeapon()

    if not weapon then
        return
    end

    GiveWeaponComponentToPed(playerPed, weapon, data.component)
    QBCore.Functions.Notify(('Installed %s.'):format(data.accessoryName), 'success')
end)

RegisterNetEvent('whellco_weapon_accessories:remove', function(data)
    local playerPed = PlayerPedId()
    local weapon = getCurrentWeapon()

    if not weapon then
        return
    end

    RemoveWeaponComponentFromPed(playerPed, weapon, data.component)
    QBCore.Functions.Notify(('Removed %s.'):format(data.accessoryName), 'success')
end)

RegisterCommand('installaccessory', function(_, args)
    local weaponName = args[1]
    local accessoryName = args[2]

    if not weaponName or not accessoryName then
        QBCore.Functions.Notify('Usage: /installaccessory [weapon] [accessory]', 'error')
        return
    end

    TriggerServerEvent('whellco_weapon_accessories:install', weaponName:upper(), accessoryName)
end, false)

RegisterCommand('removeaccessory', function(_, args)
    local weaponName = args[1]
    local accessoryName = args[2]

    if not weaponName or not accessoryName then
        QBCore.Functions.Notify('Usage: /removeaccessory [weapon] [accessory]', 'error')
        return
    end

    TriggerServerEvent('whellco_weapon_accessories:remove', weaponName:upper(), accessoryName)
end, false)