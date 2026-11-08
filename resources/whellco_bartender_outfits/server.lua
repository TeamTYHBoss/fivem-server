local QBCore = exports['qb-core']:GetCoreObject()

local outfitCooldowns = {}

local function isBartender(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.BartenderJob
end

RegisterNetEvent('whellco_bartender_outfits:apply', function(outfitIndex)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isBartender(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to use bartender outfits.', 'error')
        return
    end

    local now = os.time()

    if now - (outfitCooldowns[source] or 0) < Config.OutfitCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before changing outfits again.', 'error')
        return
    end

    local outfit = Config.Outfits[tonumber(outfitIndex) or 0]

    if not outfit then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid outfit selected.', 'error')
        return
    end

    outfitCooldowns[source] = now

    TriggerClientEvent('whellco_bartender_outfits:apply', source, {
        label = outfit.label,
        outfit = outfit
    })
end)

RegisterCommand('bartenderoutfit', function(source, args)
    local outfitIndex = args[1]

    if not outfitIndex then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /bartenderoutfit [outfit_id]', 'error')
        return
    end

    TriggerEvent('whellco_bartender_outfits:apply', outfitIndex)
end, false)