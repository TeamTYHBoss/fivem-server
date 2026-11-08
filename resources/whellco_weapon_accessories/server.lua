local QBCore = exports['qb-core']:GetCoreObject()

local function getWeaponRecord(Player, weaponName)
    return MySQL.single.await(
        [[
            SELECT id, accessories
            FROM whellco_weapon_accessories
            WHERE citizenid = ?
              AND weapon_name = ?
        ]],
        { Player.PlayerData.citizenid, weaponName }
    )
end

local function createWeaponRecord(Player, weaponName)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_weapon_accessories
                (citizenid, weapon_name, accessories)
            VALUES (?, ?, '{}')
        ]],
        { Player.PlayerData.citizenid, weaponName }
    )

    return getWeaponRecord(Player, weaponName)
end

local function getAccessories(record)
    if not record or not record.accessories then
        return {}
    end

    local ok, accessories = pcall(json.decode, record.accessories)

    if ok and type(accessories) == 'table' then
        return accessories
    end

    return {}
end

local function saveAccessories(record, accessories)
    MySQL.update.await(
        [[
            UPDATE whellco_weapon_accessories
            SET accessories = ?
            WHERE id = ?
        ]],
        { json.encode(accessories), record.id }
    )
end

RegisterNetEvent('whellco_weapon_accessories:install', function(weaponName, accessoryName)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local accessory = Config.Accessories[accessoryName]

    if not Player or not accessory then
        return
    end

    local compatible = false

    for _, weapon in ipairs(accessory.compatibleWeapons) do
        if weapon == weaponName then
            compatible = true
            break
        end
    end

    if not compatible then
        TriggerClientEvent('QBCore:Notify', source, 'This accessory is not compatible with that weapon.', 'error')
        return
    end

    local record = getWeaponRecord(Player, weaponName)

    if not record then
        record = createWeaponRecord(Player, weaponName)
    end

    local accessories = getAccessories(record)

    if accessories[accessoryName] then
        TriggerClientEvent('QBCore:Notify', source, 'Accessory already installed.', 'error')
        return
    end

    local count = 0

    for _ in pairs(accessories) do
        count = count + 1
    end

    if count >= Config.MaxAccessoriesPerWeapon then
        TriggerClientEvent('QBCore:Notify', source, 'Accessory limit reached.', 'error')
        return
    end

    if Player.Functions.GetMoney('bank') < Config.InstallCost then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money to install accessory.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', Config.InstallCost, 'Weapon accessory installation')

    accessories[accessoryName] = true
    saveAccessories(record, accessories)

    TriggerClientEvent('whellco_weapon_accessories:apply', source, {
        weaponName = weaponName,
        accessoryName = accessoryName,
        component = accessory.component
    })

    TriggerClientEvent('QBCore:Notify', source, ('Installed %s for $%d.'):format(accessory.label, Config.InstallCost), 'success')
end)

RegisterNetEvent('whellco_weapon_accessories:remove', function(weaponName, accessoryName)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local accessory = Config.Accessories[accessoryName]

    if not Player or not accessory then
        return
    end

    local record = getWeaponRecord(Player, weaponName)
    local accessories = getAccessories(record)

    if not accessories[accessoryName] then
        TriggerClientEvent('QBCore:Notify', source, 'Accessory is not installed.', 'error')
        return
    end

    if Player.Functions.GetMoney('bank') < Config.RemoveCost then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money to remove accessory.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', Config.RemoveCost, 'Weapon accessory removal')

    accessories[accessoryName] = nil
    saveAccessories(record, accessories)

    TriggerClientEvent('whellco_weapon_accessories:remove', source, {
        weaponName = weaponName,
        accessoryName = accessoryName,
        component = accessory.component
    })

    TriggerClientEvent('QBCore:Notify', source, ('Removed %s for $%d.'):format(accessory.label, Config.RemoveCost), 'success')
end)

RegisterCommand('weaponaccessories', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for name, accessory in pairs(Config.Accessories) do
        names[#names + 1] = ('%s - %s'):format(name, accessory.label)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)