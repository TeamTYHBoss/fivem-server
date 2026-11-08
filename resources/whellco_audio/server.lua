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

    local vehicles = MySQL.query.await(
        [[
            SELECT id, model, plate
            FROM whellco_vehicles
            WHERE owner_id = ?
            ORDER BY created_at DESC
        ]],
        { identifier }
    ) or {}

    local audio = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, audio_system, audio_volume, applied_at
            FROM whellco_vehicle_audio
            WHERE owner_id = ?
            ORDER BY applied_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_audio:openMenu', source, {
        vehicles = vehicles,
        audio = audio,
        systems = Config.AudioSystems,
        volumes = Config.AudioVolumes
    })
end

RegisterNetEvent('whellco_audio:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_audio:closeMenu', function()
    TriggerClientEvent('whellco_audio:closeMenu', source)
end)

RegisterNetEvent('whellco_audio:applyAudio', function(vehicleId, systemId, volumeId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    systemId = tonumber(systemId) or 0
    volumeId = tonumber(volumeId) or 0

    local vehicle = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_vehicles
            WHERE id = ? AND owner_id = ?
            LIMIT 1
        ]],
        { vehicleId, identifier }
    )

    if not vehicle then
        return
    end

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_vehicle_audio
            WHERE vehicle_id = ?
            LIMIT 1
        ]],
        { vehicleId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_vehicle_audio
                SET audio_system = ?, audio_volume = ?
                WHERE id = ?
            ]],
            { systemId, volumeId, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_vehicle_audio
                    (vehicle_id, owner_id, audio_system, audio_volume)
                VALUES (?, ?, ?, ?)
            ]],
            { vehicleId, identifier, systemId, volumeId }
        )
    end

    TriggerClientEvent('whellco_audio:notify', source, ('Audio applied for £%s.'):format(Config.AudioPrice))

    sendMenu(source)
end)
