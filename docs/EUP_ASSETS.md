# EUP & Custom Assets

`whellco_eup_assets` provides a QBCore-compatible foundation for TOS-compliant clothing, emergency-service uniforms, custom emergency vehicles, and expanded wardrobe choices.

## Important compliance note

Only include clothing, liveries, vehicle models, badges, logos, or agency-specific assets that you own, created, or are explicitly licensed to use.

Do not include real-world agency insignia, logos, or branded assets unless you have permission from the rights holder.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_eup_assets
```

## QBCore integration

- Player data uses `QBCore.Functions.GetPlayerData()`.
- Server validation uses `QBCore.Functions.GetPlayer(source)`.
- Uniform access uses `Player.PlayerData.job.name` and `Player.PlayerData.job.grade.level`.
- Vehicle access uses the same QBCore job and grade checks.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` as a dependency.

## Uniform system

Uniforms support separate male and female component variations.

```lua
Config.Uniforms.police = {
    label = 'Police Uniform',
    requiredJob = 'police',
    requiredGrade = 0,
    male = {
        tshirt = 58,
        torso = 55,
        decals = 0,
        arms = 41,
        pants = 25,
        shoes = 25
    },
    female = {
        tshirt = 35,
        torso = 48,
        decals = 0,
        arms = 44,
        pants = 34,
        shoes = 27
    }
}
```

## Emergency vehicles

The resource includes configurable police, fire, and EMS vehicle entries.

```lua
Config.Vehicles.police = {
    label = 'Police Cruiser',
    model = `police`,
    requiredJob = 'police',
    requiredGrade = 0,
    livery = 0
}
```

Custom vehicle models should be placed under:

```text
resources/whellco_eup_assets/stream/<vehicle_name>/
```

Include the required `.yft`, `.ytd`, `.ydr`, `.ydd`, `vehicles.meta`, `carcols.meta`, `vehvariations.meta`, and `vehiclelayouts.meta` files supplied by the asset creator.

## Expanded wardrobe

The wardrobe supports casual and emergency categories.

```lua
Config.WardrobeCategories.emergency = {
    label = 'Emergency Services',
    outfits = {
        { label = 'Police Uniform', uniform = 'police' },
        { label = 'Firefighter Uniform', uniform = 'fire' },
        { label = 'EMS Uniform', uniform = 'ems' }
    }
}
```

## Commands

```text
/eupmenu
```

Opens the EUP wardrobe and emergency vehicle menu.

## Security

- Uniform and vehicle access is validated server-side.
- A player cannot bypass job or grade restrictions by triggering the client event directly.
- Custom assets are streamed only through the resource manifest.
- No real-world agency branding is included by default.