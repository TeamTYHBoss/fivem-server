# Employee Panic Button

`whellco_staff_panic` provides an employee panic button for staff under threat at the strip club.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_staff_panic
```

## Database

Run:

```sql
source database/whellco_staff_panic.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Staff eligibility uses `Config.StaffJobs`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Panic rules

- Panic cooldown: 30 seconds.
- Staff jobs: `manager`, `bartender`, `dancer`, `security`.
- Players must be near the club.
- Security staff receive the alert and a map waypoint.
- Panic records store citizen ID, coordinates, message, and timestamp.

## Commands

Activate panic button:

```text
/staffpanic
```

View panic information:

```text
/staffpanicinfo
```

## Security

- Staff eligibility is validated server-side.
- Panic cooldowns are validated server-side.
- Panic location is validated server-side.
- Panic alerts are sent only to security staff.
- Panic records store citizen ID, coordinates, message, and timestamp.