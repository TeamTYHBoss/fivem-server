# Auto-Cleanup for Abandoned Vehicles and Peds

`whellco_auto_cleanup` removes abandoned vehicles and idle peds on a configurable schedule.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_auto_cleanup
```

## Database

Run:

```sql
source database/whellco_cleanup_logs.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Admin eligibility uses `Config.AdminJobs`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Cleanup rules

- Cleanup interval: 5 minutes.
- Vehicle idle threshold: 15 minutes.
- Ped idle threshold: 10 minutes.
- Maximum cleanup per cycle: 50 entities.
- Player vehicles are skipped by default.
- Mission entities are skipped by default.
- Exempt models are skipped.
- Exempt zones are skipped.

## Commands

Run cleanup manually:

```text
/cleanupnow
```

View cleanup information:

```text
/cleanupinfo
```

## Security

- Admin eligibility is validated server-side.
- Cleanup reports are validated server-side.
- Cleanup cooldowns are validated server-side.
- Cleanup logs are recorded server-side.
- Cleanup rules are configurable through `config.lua`.