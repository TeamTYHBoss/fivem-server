# Third Eye Interaction System

`whellco_ox_target` provides a QBCore-compatible third-eye interaction layer using `ox_target`.

It replaces static text prompts with raycast-based interactions for models, vehicles, peds, and zones.

## Requirements

```cfg
ensure qb-core
ensure oxmysql
ensure ox_target
ensure whellco_ox_target
```

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

## Configuration

```lua
['police_armory'] = {
    type = 'model',
    model = `prop_amb_clinic_01`,
    label = 'Police Armory',
    icon = 'fa-solid fa-shield-halved',
    distance = 2.5,
    requiredJob = 'police',
    jobGrade = 2,
    event = 'whellco_ox_target:openArmory'
}
```

## Adding a target

1. Add an entry to `Config.Targets`.
2. Choose a `type`: `model`, `vehicle`, `ped`, or `zone`.
3. Set the label, icon, distance, required job, and job grade.
4. Set the server event to trigger.
5. Restart the resource.

## Security

- The client can display an option, but the server independently validates QBCore identity and job access.
- A client cannot bypass job or grade restrictions by calling the interaction event directly.
- Server-side handlers validate the target ID before executing an action.
- Debug logging can be enabled with `Config.Debug = true`.