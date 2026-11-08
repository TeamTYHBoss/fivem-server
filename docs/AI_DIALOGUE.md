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

## Rate limits

```lua
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
```

- Each player may send at most 8 requests in any rolling 5-minute period.
- Each player must wait at least 8 seconds between requests.
- The server allows at most 30 requests in any rolling 60-second period.
- No more than 3 provider requests run concurrently.
- The queue holds up to 25 waiting requests.
- Requests older than 20 seconds are removed from the queue and the player receives a timeout notification.

## Request queue

1. Player submits a dialogue request.
2. Server validates QBCore identity, NPC, prompt, cooldown, and rolling rate limits.
3. Valid requests enter a bounded queue.
4. Up to three requests are dispatched concurrently.
5. When a provider response arrives, the queue worker starts the next request.
6. Expired queue entries are removed and players are notified.

## NPC dialogue

Players stand near a configured NPC and use:

```text
/aitalk hello, can you help me?
/aiclear
```

## Asynchronous HTTP handling

`PerformHttpRequest` is asynchronous. The AI dialogue server passes a callback through the request functions and sends the player response only after the provider responds.

## Dynamic events

Administrators can generate an event:

```text
aievent street_race
aievent delivery
aievent search
aievent rescue
aievent community
```

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
- Requests are cooldown-, rolling-window-, concurrency-, and queue-limited.
- Blocked phrases prevent sensitive or exploit-related prompts.
- AI output is truncated before being sent to clients.
- HTTP responses are decoded safely and handled through callbacks.