# Stealth Perk

`whellco_stealth_perk` provides QBCore-compatible stealth training that reduces the chance of police alerts after failed lockpicks.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_lockpick_alerts
ensure whellco_stealth_perk
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Stealth level uses `Player.PlayerData.metadata.stealth_level`.
- Alert chance is calculated server-side.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_lockpick_alerts` as dependencies.

## Stealth levels

| Level | Alert reduction | Alert chance |
|---|---:|---:|
| None | 0% | 100% |
| Basic | 20% | 80% |
| Advanced | 40% | 60% |

## Commands

Check stealth perk:

```text
/stealthinfo
```

## Security

- Stealth level and alert chance are validated server-side.
- Alert chance cannot fall below the configured minimum.
- Alert triggers are handled server-side.