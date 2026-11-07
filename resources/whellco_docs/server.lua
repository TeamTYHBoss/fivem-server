local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    local sections = {}

    for id, section in pairs(Config.DocumentationSections) do
        sections[#sections + 1] = {
            id = id,
            label = section.label,
            content = section.content
        }
    end

    TriggerClientEvent('whellco_docs:openMenu', source, {
        sections = sections
    })
end

RegisterNetEvent('whellco_docs:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_docs:closeMenu', function()
    TriggerClientEvent('whellco_docs:closeMenu', source)
end)

RegisterNetEvent('whellco_docs:viewSection', function(section)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if not Config.DocumentationSections[section] then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_docs_views
                (character_id, section)
            VALUES (?, ?)
        ]],
        { identifier, section }
    )

    TriggerClientEvent('whellco_docs:notify', source, ('Viewed %s.'):format(Config.DocumentationSections[section].label))
end)
