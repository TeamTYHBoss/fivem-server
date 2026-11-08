Config = {}

Config.Provider = 'openai'
Config.OpenAIApiKey = GetConvar('whellco_openai_key', '')
Config.AnthropicApiKey = GetConvar('whellco_anthropic_key', '')

Config.OpenAIModel = GetConvar('whellco_openai_model', 'gpt-4o-mini')
Config.AnthropicModel = GetConvar('whellco_anthropic_model', 'claude-3-5-haiku-latest')

Config.EventTypes = {
    'street_race',
    'delivery',
    'search',
    'rescue',
    'community'
}

Config.EventCooldownMinutes = 30
Config.MaxParticipants = 20
Config.RewardMoney = 2500
Config.RewardXp = 50

Config.AllowedZones = {
    vector3(215.0, -810.0, 30.7),
    vector3(-269.0, -955.0, 31.2),
    vector3(1275.0, -1710.0, 54.0)
}