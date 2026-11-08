local QBCore = exports['qb-core']:GetCoreObject()

local cooldowns = {}

local function isAllowed(npcId)
    return Config.AllowedNpcs[npcId] ~= nil
end

local function isBlocked(text)
    text = string.lower(text)

    for _, phrase in ipairs(Config.BlockedPhrases) do
        if text:find(phrase, 1, true) then
            return true
        end
    end

    return false
end

local function callOpenAI(prompt, systemPrompt)
    local response = PerformHttpRequest('https://api.openai.com/v1/chat/completions', function(status, body)
        if status ~= 200 then
            print(('[whellco_ai_dialogue] OpenAI request failed: %s'):format(status))
            return
        end

        local data = json.decode(body or '{}')
        local reply = data.choices and data.choices[1] and data.choices[1].message and data.choices[1].message.content

        if reply then
            return reply
        end
    end, 'POST', json.encode({
        model = Config.OpenAIModel,
        messages = {
            { role = 'system', content = systemPrompt },
            { role = 'user', content = prompt }
        },
        max_tokens = 180,
        temperature = 0.7
    }), {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = ('Bearer %s'):format(Config.OpenAIApiKey)
    })

    return response
end

local function callAnthropic(prompt, systemPrompt)
    local response = PerformHttpRequest('https://api.anthropic.com/v1/messages', function(status, body)
        if status ~= 200 then
            print(('[whellco_ai_dialogue] Anthropic request failed: %s'):format(status))
            return
        end

        local data = json.decode(body or '{}')
        local reply = data.content and data.content[1] and data.content[1].text

        if reply then
            return reply
        end
    end, 'POST', json.encode({
        model = Config.AnthropicModel,
        max_tokens = 180,
        system = systemPrompt,
        messages = {
            { role = 'user', content = prompt }
        }
    }), {
        ['Content-Type'] = 'application/json',
        ['x-api-key'] = Config.AnthropicApiKey,
        ['anthropic-version'] = '2023-06-01'
    })

    return response
end

RegisterNetEvent('whellco_ai_dialogue:send', function(npcId, message)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if not isAllowed(npcId) then
        TriggerClientEvent('QBCore:Notify', source, 'This NPC cannot chat.', 'error')
        return
    end

    message = tostring(message or ''):gsub('^%s+', ''):gsub('%s+$', '')

    if #message == 0 or #message > Config.MaxPromptLength then
        TriggerClientEvent('QBCore:Notify', source, 'Message is too long or empty.', 'error')
        return
    end

    if isBlocked(message) then
        TriggerClientEvent('QBCore:Notify', source, 'That message cannot be sent.', 'error')
        return
    end

    local now = os.time()
    local last = cooldowns[source] or 0

    if now - last < Config.CooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before speaking again.', 'error')
        return
    end

    cooldowns[source] = now

    local npc = Config.AllowedNpcs[npcId]
    local prompt = ('Player: %s\nNPC: %s'):format(Player.PlayerData.charinfo.firstname, message)
    local reply

    if Config.Provider == 'anthropic' then
        reply = callAnthropic(prompt, npc.systemPrompt)
    else
        reply = callOpenAI(prompt, npc.systemPrompt)
    end

    if not reply then
        TriggerClientEvent('QBCore:Notify', source, 'The NPC is unavailable right now.', 'error')
        return
    end

    reply = tostring(reply):sub(1, Config.MaxResponseLength)

    TriggerClientEvent('whellco_ai_dialogue:receive', source, {
        npcId = npcId,
        npcLabel = npc.label,
        message = reply
    })
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)