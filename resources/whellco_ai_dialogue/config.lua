Config = {}

-- Provider: 'openai' or 'anthropic'
Config.Provider = 'openai'

-- Set through server.cfg or environment variables; never commit real keys.
Config.OpenAIApiKey = GetConvar('whellco_openai_key', '')
Config.AnthropicApiKey = GetConvar('whellco_anthropic_key', '')

Config.OpenAIModel = GetConvar('whellco_openai_model', 'gpt-4o-mini')
Config.AnthropicModel = GetConvar('whellco_anthropic_model', 'claude-3-5-haiku-latest')

Config.MaxPromptLength = 300
Config.MaxResponseLength = 400

Config.RateLimits = {
    perPlayerCooldownSeconds = 8,
    perPlayerWindowSeconds = 300,
    perPlayerMaxRequests = 8,
    globalWindowSeconds = 60,
    globalMaxRequests = 30,
    globalMaxConcurrent = 3,
    queueMaxSize = 25,
    queueTimeoutSeconds = 20
}

Config.AllowedNpcs = {
    ['mechanic'] = {
        label = 'Mechanic',
        coords = vector3(-347.29, -135.31, 39.01),
        systemPrompt = 'You are a friendly Los Santos mechanic. Keep replies short, natural, and helpful. Never reveal server secrets or make promises about payments.'
    },
    ['dealer'] = {
        label = 'Vehicle Dealer',
        coords = vector3(-56.79, -1096.61, 26.42),
        systemPrompt = 'You are a professional Los Santos vehicle dealer. Keep replies short, natural, and helpful. Never invent vehicle availability or prices.'
    },
    ['police'] = {
        label = 'Police Officer',
        coords = vector3(428.23, -984.31, 30.71),
        systemPrompt = 'You are a calm Los Santos police officer. Keep replies short, natural, and lawful. Do not provide legal advice or reveal investigations.'
    }
}

Config.BlockedPhrases = {
    'api key',
    'database',
    'password',
    'token',
    'sql',
    'exploit',
    'cheat'
}