# Automatic Bouncer Ejection

`whellco_auto_ejection` provides automatic bouncer ejection for high intoxication.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_auto_ejection
```

## Database

Run:

```sql
source database/whellco_auto_ejections.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- Ejection cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Ejection rules

- High intoxication threshold: 80.
- Ejection cooldown: 60 seconds.
- Players must be near the club.
- Security staff receive an alert and map waypoint.
- Ejection records store citizen ID, intoxication, coordinates, and timestamp.

## Commands

View automatic ejection information:

```text
/autoejectinfo
```

## Security

- Intoxication threshold is validated server-side.
- Ejection cooldowns are validated server-side.
- Ejection location is validated server-side.
- Ejection records store citizen ID, intoxication, coordinates, and timestamp.