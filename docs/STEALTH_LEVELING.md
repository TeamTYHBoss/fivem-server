# Stealth Perk Leveling

`whellco_stealth_leveling` provides QBCore-compatible stealth perk leveling through successful and failed lockpicks.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_stealth_perk
ensure whellco_stealth_leveling
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Stealth XP uses `Player.PlayerData.metadata.stealth_xp`.
- Stealth level uses `Player.PlayerData.metadata.stealth_level`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_stealth_perk` as dependencies.

## Leveling rules

- XP per successful lockpick: 10.
- XP per failed lockpick: 2.
- Maximum stealth level: 3.
- Level 2 requires 50 XP.
- Level 3 requires 150 XP.

## Commands

Check stealth XP:

```text
/stealthxp
```

## Security

- XP amounts are validated server-side.
- Stealth XP and level are stored in QBCore metadata.
- Level progression is calculated server-side.