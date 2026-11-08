local QBCore = exports['qb-core']:GetCoreObject()

local activeEvents = {}
local lastEventTime = 0

local function generatePrompt(eventType, zone)
    return table.concat({
        'Create a short, safe, roleplay-friendly FiveM event for a QBCore server.',
        ('Event type: %s'):format(eventType),
        ('Location: %.2f, %.2f, %.2f'):format(zone.x, zone.y, zone.z),
        'Return JSON only with keys: title, description, objective, reward.',
        'Keep description under 180 characters and do not include weapons, crimes, or unsafe instructions.'
    }, '\n')
end

local function requestEvent(eventType, zone)
    local prompt = generatePrompt(eventType, zone)
    local body
    local headers
    local url

    if Config.Provider == 'anthropic' then
        url = 'https://api.anthropic.com/v1/messages'
        headers = {
            ['Content-Type'] = 'application/json',
            ['x-api-key'] = Config.AnthropicApiKey,
            ['anthropic-version'] = '2023-06-01'
        }
        body = json.encode({
            model = Config.AnthropicModel,
            max_tokens = 300,
            messages = {
                { role = 'user', content = prompt }
            }
        })
    else
        url = 'https://api.openai.com/v1/chat/completions'
        headers = {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = ('Bearer %s'):format(Config.OpenAIApiKey)
        }
        body = json.encode({
            model = Config.OpenAIModel,
            messages = {
                { role = 'user', content = prompt }
            },
            max_tokens = 300,
            temperature = 0.8
        })
    end

    PerformHttpRequest(url, function(status, response)
        if status ~= 200 then
            print(('[whellco_ai_events] AI request failed: %s'):format(status))
            return
        end

        local data = json.decode(response or '{}')
        local text

        if Config.Provider == 'anthropic' then
            text = data.content and data.content[1] and data.content[1].text
        else
            text = data.choices and data.choices[1] and data.choices[1].message and data.choices[1].message.content
        end

        if not text then
            return
        end

        local jsonStart = text:find('{')
        local jsonEnd = text:find('}', -1)

        if not jsonStart or not jsonEnd then
            return
        end

        local ok, event = pcall(json.decode, text:sub(jsonStart, jsonEnd))

        if not ok or type(event) ~= 'table' then
            return
        end

        activeEvents[eventType] = {
            title = tostring(event.title or 'Dynamic Event'):sub(1, 64),
            description = tostring(event.description or ''):sub(1, 180),
            objective = tostring(event.objective or 'Complete the event objective.'):sub(1, 180),
            reward = Config.RewardMoney,
            zone = zone,
            startedAt = os.time()
        }

        TriggerClientEvent('whellco_ai_events:announce', -1, {
            type = eventType,
            title = activeEvents[eventType].title,
            description = activeEvents[eventType].description,
            objective = activeEvents[eventType].objective,
            coords = zone
        })
    end, 'POST', body, headers)
end

RegisterCommand('aievent', function(source, args)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)

        if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('QBCore:Notify', source, 'You do not have permission.', 'error')
            return
        end
    end

    local eventType = tostring(args[1] or '')

    if not eventType or not Config.EventTypes[eventType] then
        return
    end

    local now = os.time()

    if now - lastEventTime < Config.EventCooldownMinutes * 60 then
        return
    end

    lastEventTime = now

    local zone = Config.AllowedZones[math.random(#Config.AllowedZones)]

    requestEvent(eventType, zone)
end, false)

RegisterNetEvent('whellco_ai_events:complete', function(eventType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local event = activeEvents[eventType]

    if not Player or not event then
        return
    end

    activeEvents[eventType] = nil

    Player.Functions.AddMoney('bank', event.reward, 'AI dynamic event reward')
    Player.Functions.SetMetaData('whellco_xp', (Player.PlayerData.metadata.whellco_xp or 0) + Config.RewardXp)

    TriggerClientEvent('QBCore:Notify', source, ('Event complete. $%s and %s XP awarded.'):format(event.reward, Config.RewardXp), 'success')
end)