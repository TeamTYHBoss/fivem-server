local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local plates = MySQL.query.await(
        [[
            SELECT id, plate, rarity_level, rarity_value, created_at
            FROM whellco_plate_rarity
            ORDER BY rarity_value DESC
        ]]
    ) or {}

    TriggerClientEvent('whellco_plate_rarity:openMenu', source, {
        plates = plates,
        rarityLevels = Config.RarityLevels
    })
end

RegisterNetEvent('whellco_plate_rarity:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_plate_rarity:closeMenu', function()
    TriggerClientEvent('whellco_plate_rarity:closeMenu', source)
end)

RegisterNetEvent('whellco_plate_rarity:setRarity', function(plate, rarityLevel)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    rarityLevel = tonumber(rarityLevel) or 0

    local rarity = nil

    for _, level in ipairs(Config.RarityLevels) do
        if level.id == rarityLevel then
            rarity = level
            break
        end
    end

    if not rarity then
        return
    end

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_plate_rarity
            WHERE plate = ?
            LIMIT 1
        ]],
        { plate }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_plate_rarity
                SET rarity_level = ?, rarity_value = ?
                WHERE id = ?
            ]],
            { rarity.id, rarity.value, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_plate_rarity
                    (plate, rarity_level, rarity_value)
                VALUES (?, ?, ?)
            ]],
            { plate, rarity.id, rarity.value }
        )
    end

    TriggerClientEvent('whellco_plate_rarity:notify', source, ('Plate %s set to %s rarity.'):format(plate, rarity.name))

    sendMenu(source)
end)
