# Third Eye Interaction System

`whellco_ox_target` provides a QBCore-compatible third-eye interaction layer using `ox_target`, with visual feedback, icons, highlight markers, and audio cues.

## Requirements

```cfg
ensure qb-core
ensure oxmysql
ensure ox_target
ensure whellco_ox_target
```

## Visual feedback

```lua
Config.VisualFeedback = {
    enabled = true,
    highlightColor = { 0, 150, 255 },
    highlightAlpha = 120,
    highlightDistance = 2.5,
    successSound = 'SELECT',
    successSoundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET',
    errorSound = 'ERROR',
    errorSoundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
}
```

Each target can override its feedback icon, colour, and sound:

```lua
feedback = {
    icon = 'fa-solid fa-shield-halved',
    color = '#0096ff',
    sound = 'SELECT'
}
```

## Feedback behavior

- Selecting a target shows a short coloured highlight marker.
- Zone targets display an interaction icon when the player is close enough.
- Successful interactions play a success sound and show a success notification.
- Failed or unauthorised interactions play an error sound and show an error notification.
- The global feedback system can be disabled with `Config.VisualFeedback.enabled = false`.

## QBCore compatibility

- Client-side access checks use `QBCore.Functions.GetPlayerData()`.
- Server-side validation uses `QBCore.Functions.GetPlayer(source)`.
- Job access uses `Player.PlayerData.job.name`.
- Job-grade access uses `Player.PlayerData.job.grade.level`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares both `qb-core` and `ox_target` as dependencies.

## Target types

| Type | Use case |
|---|---|
| `model` | Props, doors, machines, and static objects |
| `vehicle` | Any nearby vehicle |
| `ped` | NPC interactions |
| `zone` | Fixed world locations such as stashes, counters, or terminals |

## Security

- The client can display an option, but the server independently validates QBCore identity and job access.
- A client cannot bypass job or grade restrictions by calling the interaction event directly.
- Server-side handlers validate the target ID before executing an action.
- Debug logging can be enabled with `Config.Debug = true`.