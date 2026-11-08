# Immersive Interiors

`whellco_immersive_interiors` provides QBCore-native custom MLO interiors, seamless entry and exit points, job-gated rooms, interactive interior locations, and polished teleport transitions with audio cues and cooldown protection.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_immersive_interiors
```

## Teleport transitions

```lua
Config.TeleportTransition = {
    enabled = true,
    fadeOutMs = 400,
    fadeInMs = 500,
    particleEffect = 'scr_reconstructiontrust',
    particleName = 'scr_reconstruction_trust',
    particleDurationMs = 900,
    cooldownMs = 5000,
    audio = {
        enabled = true,
        departureSound = 'CHECKPOINT_PERFECT',
        departureSoundSet = 'HUD_MINI_GAME_SOUNDSET',
        arrivalSound = 'SELECT',
        arrivalSoundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET',
        departureDelayMs = 0,
        arrivalDelayMs = 300
    }
}
```

- `cooldownMs` prevents teleport spam.
- The default cooldown is 5 seconds.
- Set `cooldownMs = 0` to disable the cooldown.
- The cooldown applies to both normal interior entry/exit and `/interiortp`.
- Players receive a QBCore notification showing the remaining cooldown.

## Admin teleport commands

List configured interiors:

```text
/interiors
```

Teleport to an interior entrance:

```text
/interiortp police_station
/interiortp mansion
/interiortp hidden_room
```

Teleport to an interior exit:

```text
/interiortp police_station exit
/interiortp mansion exit
/interiortp hidden_room exit
```

## QBCore integration

- Player data uses `QBCore.Functions.GetPlayerData()`.
- Server validation uses `QBCore.Functions.GetPlayer(source)`.
- Admin checks use `QBCore.Functions.HasPermission(source, 'admin')`.
- Job access uses `Player.PlayerData.job.name` and `Player.PlayerData.job.grade.level`.
- Notifications use `QBCore.Functions.Notify`.

## MLO assets

Place custom assets in:

```text
resources/whellco_immersive_interiors/stream/
```

Supported asset types:

- `.ytd`
- `.ydr`
- `.ydd`
- `.ybn`
- `.ymap`

## Adding an interior

```lua
['my_interior'] = {
    label = 'My Custom Interior',
    interior = 'my_interior',
    entry = vector3(x, y, z),
    exit = vector3(x, y, z),
    requiredJob = nil,
    jobGrade = 0,
    rooms = { 'main_room' }
}
```

## Adding an interaction

```lua
Config.Interactions['my_interior'] = {
    {
        id = 'safe',
        label = 'Open Safe',
        coords = vector3(x, y, z),
        requiredJob = nil,
        jobGrade = 0
    }
}
```