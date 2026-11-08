Utils = Utils or {}

function Utils.Notify(source, message, kind)
    TriggerClientEvent('QBCore:Notify', source, message, kind or 'primary', 5000)
end

function Utils.GetPlayer(source)
    local QBCore = exports['qb-core']:GetCoreObject()

    return QBCore.Functions.GetPlayer(source)
end

function Utils.GetPlayerByCitizenId(citizenId)
    local QBCore = exports['qb-core']:GetCoreObject()

    return QBCore.Functions.GetPlayerByCitizenId(citizenId)
end

function Utils.Trim(value)
    if type(value) ~= 'string' then
        return ''
    end

    local trimmed = value:gsub('^%s+', '')
    trimmed = trimmed:gsub('%s+$', '')

    return trimmed
end

function Utils.CreateCooldown(defaultMilliseconds)
    local cooldowns = {}
    local cooldownTime = defaultMilliseconds or 1000

    local cooldown = {}

    function cooldown.IsOnCooldown(source)
        local now = GetGameTimer()
        local lastAction = cooldowns[source] or 0

        return now - lastAction < cooldownTime
    end

    function cooldown.SetCooldown(source)
        cooldowns[source] = GetGameTimer()
    end

    function cooldown.Clear(source)
        cooldowns[source] = nil
    end

    return cooldown
end

function Utils.ValidatePositiveInteger(value, minimum, maximum)
    local number = tonumber(value)

    if not number then
        return nil
    end

    number = math.floor(number)

    local minimumValue = minimum or 1

    if number < minimumValue then
        return nil
    end

    if maximum and number > maximum then
        return nil
    end

    return number
end

function Utils.SafeJsonEncode(value)
    if type(value) ~= 'table' then
        value = {}
    end

    local success, encoded = pcall(json.encode, value)

    if success and type(encoded) == 'string' then
        return encoded
    end

    return '{}'
end

function Utils.SafeJsonDecode(value)
    if type(value) ~= 'string' or value == '' then
        return {}
    end

    local success, decoded = pcall(json.decode, value)

    if success and type(decoded) == 'table' then
        return decoded
    end

    return {}
end

function Utils.FormatMoney(amount)
    local number = tonumber(amount) or 0

    return ('$%d'):format(math.floor(number))
end
