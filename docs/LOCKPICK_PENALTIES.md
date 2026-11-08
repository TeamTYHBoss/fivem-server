# Lockpick Failure Penalties

`whellco_lockpick_penalties` adds QBCore-compatible lockpick breakage penalties after failed lockpicking attempts.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_theft
ensure whellco_lockpick_penalties
```

## Penalty rules

- Break chance: 35%.
- Minimum lockpicks broken: 1.
- Maximum lockpicks broken: 2.
- Penalty cooldown: 10 seconds.
- Eligible items: lockpick, advanced_lockpick.

## Commands

Test the penalty:

```text
/testlockpickpenalty
```

## Security

- Break chance and cooldowns are validated server-side.
- Lockpick removal is validated server-side.
- Players cannot lose more lockpicks than they possess.
- Penalty events are rate-limited.