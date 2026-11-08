# Immersive Interiors

`whellco_immersive_interiors` provides QBCore-native custom MLO interiors, seamless entry and exit points, job-gated rooms, interactive interior locations, teleport transitions, audio cues, cooldown protection, and a loading screen for heavy map transitions.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_immersive_interiors
```

## Loading screen

```lua
Config.TeleportTransition.loadingScreen = {
    enabled = true,
    minimumMs = 1200,
    maximumMs = 6000,
    title = 'Loading Interior',
    subtitle = 'Preparing the environment...',
    backgroundColor = { 10, 10, 15 },
    accentColor = { 0, 150, 255 }
}
```

- The loading screen appears before a heavy interior transition.
- It remains visible for at least `minimumMs`.
- It is automatically hidden after the interior loads and the teleport transition completes.
- The title, subtitle, background colour, and accent colour are configurable.
- Set `enabled = false` to disable the loading screen.

## Teleport transitions

```lua
Config.TeleportTransition = {
    enabled = true,
    cooldownMs = 5000,
    fadeOutMs = 400,
    fadeInMs = 500,
    particleEffect = 'scr_reconstructiontrust',
    particleName = 'scr_reconstruction_trust',
    particleDurationMs = 900,
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