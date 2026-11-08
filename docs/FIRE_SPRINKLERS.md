# Automated Fire Sprinkler System

`whellco_fire_sprinklers` provides an automated fire sprinkler system for the strip club.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_fire_sprinklers
```

## Database

Run:

```sql
source database/whellco_fire_sprinklers.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Authorised jobs are `manager` and `security`.
- Sprinkler cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Sprinkler rules

- Sprinkler duration: 60 seconds.
- Sprinkler cooldown: 120 seconds.
- Authorised jobs: `manager`, `security`.
- Sprinkler zones are defined in config.
- Sprinkler records store staff, zone, and timestamp.

## Commands

Activate sprinklers:

```text
/sprinklers 1
/sprinklers 2
```

View sprinkler information:

```text
/sprinklerinfo
```

## Security

- Authorisation is validated server-side.
- Sprinkler cooldowns are validated server-side.
- Sprinkler zones are validated server-side.
- Sprinkler records store staff, zone, and timestamp.