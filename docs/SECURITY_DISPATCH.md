# Security Dispatch Alerts

`whellco_security_dispatch` provides security dispatch alerts for panicked patrons at the strip club.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_security_dispatch
```

## Database

Run:

```sql
source database/whellco_security_dispatch.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- Dispatch cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Dispatch rules

- Dispatch cooldown: 30 seconds.
- Players must be near the club.
- Security staff receive the alert and a map waypoint.
- Dispatch records store citizen ID, coordinates, message, and timestamp.

## Commands

Send a panic alert:

```text
/panic
```

View dispatch information:

```text
/dispatchinfo
```

## Security

- Dispatch cooldowns are validated server-side.
- Dispatch location is validated server-side.
- Dispatch alerts are sent only to security staff.
- Dispatch records store citizen ID, coordinates, message, and timestamp.