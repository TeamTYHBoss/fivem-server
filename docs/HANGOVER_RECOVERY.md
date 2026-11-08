# Hangover Recovery Mechanic

`whellco_hangover_recovery` provides a hangover recovery mechanic for patrons.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_hangover_recovery
```

## Database

Run:

```sql
source database/whellco_hangover_recovery.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Recovery items use `Player.Functions.RemoveItem(itemName, 1)`.
- Recovery cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Recovery rules

- Recovery cooldown: 30 seconds.
- Hangover threshold: 50.
- Recovery items: `water_bottle`, `coffee`, `painkillers`.
- Recovery amounts: 10, 15, 25.
- Players must be near the club.
- Recovery records store patron, item, intoxication before, intoxication after, and timestamp.

## Commands

Recover from hangover:

```text
/recover water_bottle
/recover coffee
/recover painkillers
```

View recovery information:

```text
/recoverinfo
```

## Security

- Recovery cooldowns are validated server-side.
- Recovery location is validated server-side.
- Recovery items are validated server-side.
- Recovery records store patron, item, intoxication before, intoxication after, and timestamp.