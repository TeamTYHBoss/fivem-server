# WhellCo Immersive Interiors

A QBCore-native foundation for custom MLO interiors, seamless entry and exit points, job-gated rooms, and interactive interior locations.

## Features

- QBCore job and grade checks.
- Distance-based interior loading and unloading.
- Seamless entry and exit teleports within the same map area.
- Interactive police stations, mansions, and hidden rooms.
- Server-validated interactions.
- QBCore notifications.
- Support for streamed MLO assets.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_immersive_interiors
```

## MLO assets

Place custom interior assets in:

```text
resources/whellco_immersive_interiors/stream/
```

Supported asset types:

- `.ytd`
- `.ydr`
- `.ydd`
- `.ybn`
- `.ymap`

The resource manifest already registers the `stream/` folder and marks the resource as a map resource.

## Adding an interior

Add an entry to `config.lua`:

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

## QBCore integration

- Player data is read through `QBCore.Functions.GetPlayerData()`.
- Server interactions validate `QBCore.Functions.GetPlayer(source)`.
- Job access uses `Player.PlayerData.job.name` and `Player.PlayerData.job.grade.level`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` as a dependency.

## Commands

```text
/interiors
```

Lists configured interior IDs and labels.