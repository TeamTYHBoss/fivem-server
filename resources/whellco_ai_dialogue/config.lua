Config = {}

-- Provider: 'openai' or 'anthropic'
Config.Provider = 'openai'

-- Set through server.cfg or environment variables; never commit real keys.
Config.OpenAIApiKey = GetConvar('whellco_openai_key', '')
Config.AnthropicApiKey = GetConvar('whellco_anthropic_key', '')

Config.OpenAIModel = GetConvar('whellco_openai_model', 'gpt-4o-mini')
Config.AnthropicModel = GetConvar('whellco_anthropic_model', 'claude-3-5-haiku-latest')

Config.MaxPromptLength = 500
Config.MaxResponseLength = 500
Config.CooldownSeconds = 3

Config.AllowedNpcs = {
    ['mechanic'] = {
        label = 'Mechanic',
        systemPrompt = 'You are a friendly Los Santos mechanic. Keep replies short, natural, and helpful. Never reveal server secrets or make promises about payments.'
    },
    ['dealer'] = {
        label = 'Vehicle Dealer',
        systemPrompt = 'You are a professional Los Santos vehicle dealer. Keep replies short, natural, and helpful. Never invent vehicle availability or prices.'
    },
    ['police'] = {
        label = 'Police Officer',
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