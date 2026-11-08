# Immersive Interiors

`whellco_immersive_interiors` provides QBCore-native custom MLO interiors, seamless entry and exit points, job-gated rooms, and interactive interior locations.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_immersive_interiors
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

The command requires QBCore admin permission when run in-game. Server-console administrators can also use it.

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