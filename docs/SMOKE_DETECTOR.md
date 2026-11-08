# Smoke Detector Hazard Alert System

`whellco_smoke_detector` provides smoke detector hazard alerts for the strip club.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_smoke_detector
```

## Database

Run:

```sql
source database/whellco_smoke_hazards.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Alert recipients are `manager` and `security` jobs.
- Alert cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Hazard rules

- Alert cooldown: 30 seconds.
- Players must be near a smoke detector.
- Alerts are sent to management and security.
- Hazard records store reporter, detector, coordinates, message, and timestamp.

## Commands

Report smoke hazard:

```text
/smokehazard
```

View hazard information:

```text
/smokehazardinfo
```

## Security

- Alert cooldowns are validated server-side.
- Detector proximity is validated server-side.
- Hazard alerts are sent only to authorised staff.
- Hazard records store reporter, detector, coordinates, message, and timestamp.