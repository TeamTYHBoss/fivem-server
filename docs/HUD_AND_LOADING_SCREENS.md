# Custom HUD & Loading Screens

The server includes two QBCore-compatible interface resources:

- `whellco_hud`: customizable health, armour, stamina, needs, stress, oxygen, voice, and minimap HUD.
- `whellco_loading_screen`: HTML-based loading screen with embedded audio and video.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_hud
ensure whellco_loading_screen
```

## HUD features

- Health, armour, stamina, hunger, thirst, stress, and oxygen bars.
- QBCore metadata integration for hunger, thirst, and stress.
- Configurable colours and layout positions.
- `default` and `compact` layout presets.
- `/hudtoggle` to show or hide the HUD.
- `/hudlayout default` or `/hudlayout compact` to change layout.
- `/hudsave` to save HUD preferences.

## QBCore integration

- Player data uses `QBCore.Functions.GetPlayerData()`.
- HUD values use QBCore metadata fields:

```lua
playerData.metadata.hunger
playerData.metadata.thirst
playerData.metadata.stress
```

- Player load and unload events use:

```lua
QBCore:Client:OnPlayerLoaded
QBCore:Client:OnPlayerUnload
```

- Notifications use `QBCore.Functions.Notify`.
- Both resources declare `qb-core` as a dependency.

## Loading screen

Place media here:

```text
resources/whellco_loading_screen/html/media/audio.mp3
resources/whellco_loading_screen/html/media/video.mp4
```

The loading screen supports:

- Background video playback.
- Looping background audio.
- Animated progress bar.
- Custom branding and colours.
- Manual shutdown after FiveM loading completes.

## Important media note

Only include audio and video you own, created, or are licensed to use. Do not include copyrighted music, video, logos, or branding without permission.