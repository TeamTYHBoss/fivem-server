Utils = Utils or {}

function Utils.Notify(message, kind)
    TriggerEvent('QBCore:Notify', message, kind or 'primary', 5000)
end

function Utils.Trim(value)
    if type(value) ~= 'string' then
        return ''
    end

    local trimmed = value:gsub('^%s+', '')
    trimmed = trimmed:gsub('%s+$', '')

    return trimmed
end

function Utils.FormatMoney(amount)
    local number = tonumber(amount) or 0

    return ('$%d'):format(math.floor(number))
end
