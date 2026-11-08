local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    TriggerClientEvent('whellco_release:openMenu', source, {
        version = Config.Version,
        releases = Config.ReleaseNotes
    })
end

RegisterNetEvent('whellco_release:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_release:closeMenu', function()
    TriggerClientEvent('whellco_release:closeMenu', source)
end)

RegisterNetEvent('whellco_release:viewRelease', function(version)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_release_views
                (character_id, version)
            VALUES (?, ?)
        ]],
        { identifier, version }
    )

    TriggerClientEvent('whellco_release:notify', source, ('Viewed release %s.'):format(version))
end)
