# AI & Natural Dialogue

The server includes two QBCore-native AI systems:

- `whellco_ai_dialogue`: natural-language NPC conversations.
- `whellco_ai_events`: dynamic, server-wide event generation.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_ai_dialogue
ensure whellco_ai_events
```

## API keys

Set keys through `server.cfg` or environment variables. Never commit API keys.

```cfg
set whellco_openai_key "your_openai_key"
set whellco_anthropic_key "your_anthropic_key"
```

## Provider selection

In each resource’s `config.lua`:

```lua
Config.Provider = 'openai' -- or 'anthropic'
```

## NPC dialogue

Players stand near a configured NPC and use:

```text
/aitalk hello, can you help me?
/aiclear
```

The server validates the QBCore player, NPC, prompt length, cooldown, and blocked phrases before sending a request.

## Dynamic events

Administrators can generate an event:

```text
aievent street_race
aievent delivery
aievent search
aievent rescue
aievent community
```

The system requests a JSON event from the selected AI provider, validates the response, announces it to players, and rewards completion through QBCore money and XP metadata.

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Player records use `Player.PlayerData.citizenid`.
- Rewards use `Player.Functions.AddMoney('bank', amount, reason)`.
- XP uses `Player.Functions.SetMetaData('whellco_xp', value)`.
- Notifications use `QBCore.Functions.Notify`.
- Admin commands use `QBCore.Functions.HasPermission(source, 'admin')`.

## Safety

- API keys are server-side only.
- Player prompts are length-limited.
- Requests are cooldown-limited.
- Blocked phrases prevent sensitive or exploit-related prompts.
- AI output is truncated before being sent to clients.
- Dynamic events use a JSON extraction and validation step before activation.