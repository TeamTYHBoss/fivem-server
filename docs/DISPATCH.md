# Emergency Dispatch Notifications

`whellco_dispatch` provides QBCore-native dispatch notifications for police, fire, and EMS emergency calls.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_dispatch
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Eligible responders are selected through `QBCore.Functions.GetQBCorePlayers()`.
- Job filtering uses `Player.PlayerData.job.name`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` as a dependency.

## Call types

| Call type | Responders | Priority |
|---|---|---:|
| `officer_down` | Police | 3 |
| `structure_fire` | Fire Department | 3 |
| `medical_emergency` | EMS | 3 |
| `vehicle_theft` | Police | 2 |
| `robbery` | Police | 3 |
| `traffic_collision` | Police and EMS | 1 |

## Commands

Send a dispatch call:

```text
/dispatch robbery armed suspect near Legion Square
/dispatch medical_emergency unconscious player near Grove Street
/dispatch structure_fire large fire at the docks
```

Clear a dispatch call:

```text
/dispatchclear 1
```

## Features

- QBCore job-based dispatch routing.
- Per-call cooldown to prevent spam.
- Map blips with configurable sprite and colour.
- Automatic blip cleanup after 120 seconds.
- Emergency audio cues.
- Server-side call validation.
- Configurable call types, responder jobs, priorities, and sounds.

## Security

- Dispatch calls are validated server-side.
- Call details are limited to 180 characters.
- Players can only clear calls assigned to their QBCore job.
- The dispatch cooldown prevents repeated calls from the same player.
- Blips are automatically removed after their configured lifetime.