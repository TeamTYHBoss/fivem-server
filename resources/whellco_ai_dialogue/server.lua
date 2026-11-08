local QBCore = exports['qb-core']:GetCoreObject()

local playerRequests = {}
local globalRequests = {}
local activeRequests = 0
local queue = {}

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

local function pruneTimestamps(timestamps, windowSeconds)
    local now = os.time()
    local valid = {}

    for _, timestamp in ipairs(timestamps) do
        if now - timestamp <= windowSeconds then
            valid[#valid + 1] = timestamp
        end
    end

    return valid
end

local function canRequest(source)
    local limits = Config.RateLimits
    local now = os.time()

    playerRequests[source] = pruneTimestamps(playerRequests[source] or {}, limits.perPlayerWindowSeconds)
    globalRequests = pruneTimestamps(globalRequests, limits.globalWindowSeconds)

    if #playerRequests[source] >= limits.perPlayerMaxRequests then
        return false, 'You have reached the AI dialogue limit. Please try again later.'
    end

    if #globalRequests >= limits.globalMaxRequests then
        return false, 'AI dialogue is busy. Please try again shortly.'
    end

    if now - (cooldowns[source] or 0) < limits.perPlayerCooldownSeconds then
        return false, 'Please wait before speaking again.'
    end

    return true
end

local function recordRequest(source)
    local now = os.time()

    playerRequests[source] = playerRequests[source] or {}
    playerRequests[source][#playerRequests[source] + 1] = now
    globalRequests[#globalRequests + 1] = now
    cooldowns[source] = now
end

local function processQueue()
    while activeRequests < Config.RateLimits.globalMaxConcurrent and #queue > 0 do
        local job = table.remove(queue, 1)

        if job then
            activeRequests = activeRequests + 1
            job.execute(function()
                activeRequests = math.max(0, activeRequests - 1)
                processQueue()
            end)
        end
    end
end

local function enqueue(source, npc, prompt, callback)
    if #queue >= Config.RateLimits.queueMaxSize then
        TriggerClientEvent('QBCore:Notify', source, 'AI dialogue queue is full. Please try again shortly.', 'error')
        return
    end

    queue[#queue + 1] = {
        source = source,
        npc = npc,
        prompt = prompt,
        callback = callback,
        queuedAt = os.time()
    }

    processQueue()
end

local function request(url, body, headers, callback)
    PerformHttpRequest(url, function(status, responseBody)
        local ok, data = pcall(json.decode, responseBody or '{}')

        if status ~= 200 or not ok or type(data) ~= 'table' then
            callback(nil, ('HTTP request failed with status %s'):format(status))
            return
        end

        callback(data, nil)
    end, 'POST', json.encode(body), headers)
end

local function callOpenAI(prompt, systemPrompt, callback)
    request(
        'https://api.openai.com/v1/chat/completions',
        {
            model = Config.OpenAIModel,
            messages = {
                { role = 'system', content = systemPrompt },
                { role = 'user', content = prompt }
            },
            max_tokens = 180,
            temperature = 0.7
        },
        {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = ('Bearer %s'):format(Config.OpenAIApiKey)
        },
        function(data, error)
            if error then
                callback(nil, error)
                return
            end

            local reply = data.choices
                and data.choices[1]
                and data.choices[1].message
                and data.choices[1].message.content

            if not reply then
                callback(nil, 'OpenAI response did not contain a message.')
                return
            end

            callback(reply, nil)
        end
    )
end

local function callAnthropic(prompt, systemPrompt, callback)
    request(
        'https://api.anthropic.com/v1/messages',
        {
            model = Config.AnthropicModel,
            max_tokens = 180,
            system = systemPrompt,
            messages = {
                { role = 'user', content = prompt }
            }
        },
        {
            ['Content-Type'] = 'application/json',
            ['x-api-key'] = Config.AnthropicApiKey,
            ['anthropic-version'] = '2023-06-01'
        },
        function(data, error)
            if error then
                callback(nil, error)
                return
            end

            local reply = data.content
                and data.content[1]
                and data.content[1].text

            if not reply then
                callback(nil, 'Anthropic response did not contain a message.')
                return
            end

            callback(reply, nil)
        end
    )
end

local function dispatch(job, done)
    local source = job.source
    local npc = job.npc

    local callback = function(reply, error)
        if not reply then
            TriggerClientEvent('QBCore:Notify', source, 'The NPC is unavailable right now.', 'error')
            print(('[whellco_ai_dialogue] %s'):format(error or 'Unknown AI error'))
        else
            reply = tostring(reply):sub(1, Config.MaxResponseLength)

            TriggerClientEvent('whellco_ai_dialogue:receive', source, {
                npcId = job.npcId,
                npcLabel = npc.label,
                message = reply
            })
        end

        done()
    end

    if Config.Provider == 'anthropic' then
        callAnthropic(job.prompt, npc.systemPrompt, callback)
    else
        callOpenAI(job.prompt, npc.systemPrompt, callback)
    end
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

    local allowed, error = canRequest(source)

    if not allowed then
        TriggerClientEvent('QBCore:Notify', source, error, 'error')
        return
    end

    recordRequest(source)

    local npc = Config.AllowedNpcs[npcId]
    local prompt = ('Player: %s\nNPC: %s'):format(Player.PlayerData.charinfo.firstname, message)

    enqueue(source, npc, prompt, function()
        -- Placeholder to retain a stable queue interface.
    end)

    -- Dispatch immediately through the queue-controlled worker.
    local job = queue[#queue]

    if job then
        job.npcId = npcId
        job.execute = function(done)
            dispatch(job, done)
        end

        processQueue()
    end
end)

CreateThread(function()
    while true do
        Wait(5000)

        local now = os.time()
        local remaining = {}

        for index = #queue, 1, -1 do
            local job = queue[index]

            if now - job.queuedAt > Config.RateLimits.queueTimeoutSeconds then
                TriggerClientEvent('QBCore:Notify', job.source, 'AI dialogue request timed out.', 'error')
                table.remove(queue, index)
            else
                remaining[#remaining + 1] = job
            end
        end

        queue = remaining
        processQueue()
    end
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
    playerRequests[source] = nil
end)