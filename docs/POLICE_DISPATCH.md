# Police Dispatch System

`whellco_police_dispatch` provides QBCore-compatible police dispatch notifications, GPS routing, call types, and automatic cleanup.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_police_dispatch
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police eligibility uses `Player.PlayerData.job.name`.
- Police players are selected through `QBCore.Functions.GetQBCorePlayers()`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` as a dependency.

## Call types

| Call type | Priority | Responders |
|---|---:|---|
| `officer_down` | 3 | Police |
| `robbery` | 3 | Police |
| `vehicle_theft` | 2 | Police |
| `pursuit` | 3 | Police |
| `shots_fired` | 3 | Police |

## Commands

Send a police dispatch call:

```text
/policedispatch robbery armed suspect near Legion Square
/policedispatch pursuit suspect fleeing south on the highway
/policedispatch shots_fired shots fired near the docks
```

Set a GPS route:

```text
/policedispatchroute 1
```

Clear a dispatch call:

```text
/policedispatchclear 1
```

## Features

- QBCore job-based police dispatch routing.
- Priority-based automatic GPS routing.
- Map blips with configurable sprite and colour.
- Emergency audio cues.
- Per-player dispatch cooldown.
- Automatic route and call cleanup.
- Server-side call validation.

## Security

- Police dispatch calls are validated server-side.
- Only QBCore police jobs can request routes or clear calls.
- Call details are limited to 180 characters.
- The dispatch cooldown prevents repeated calls from the same player.
- Calls and routes expire automatically.