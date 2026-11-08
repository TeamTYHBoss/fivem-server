local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function isAdmin(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return false
    end

    return IsPlayerAceAllowed(source, 'whellco.admin')
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local sections = {}

    for id, section in pairs(Config.HandoverSections) do
        sections[#sections + 1] = {
            id = id,
            label = section.label,
            content = section.content
        }
    end

    local signoffs = MySQL.query.await(
        [[
            SELECT id, section, signed_off, created_at
            FROM whellco_handover_signoffs
            WHERE character_id = ?
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_handover:openMenu', source, {
        sections = sections,
        signoffs = signoffs
    })
end

RegisterNetEvent('whellco_handover:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_handover:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_handover:closeMenu', function()
    TriggerClientEvent('whellco_handover:closeMenu', source)
end)

RegisterNetEvent('whellco_handover:signOffSection', function(section)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if not isAdmin(source) then
        TriggerClientEvent('whellco_handover:notify', source, 'You do not have admin permissions.')
        return
    end

    if not Config.HandoverSections[section] then
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_handover_signoffs
                (character_id, section, signed_off)
            VALUES (?, ?, 1)
            ON DUPLICATE KEY UPDATE signed_off = 1
        ]],
        { identifier, section }
    )

    TriggerClientEvent('whellco_handover:notify', source, ('Signed off %s.'):format(Config.HandoverSections[section].label))
    sendMenu(source)
end)
