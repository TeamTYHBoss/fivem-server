# Anti-Lag System

`whellco_anti_lag` monitors client performance and limits lag-inducing activity.

## Important limitation

No client-side system can fully prevent server lag. Server performance depends on resource optimisation, database queries, hosting capacity, and network conditions. This system adds monitoring, rate limits, and graduated enforcement.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_anti_lag
```

## Database

Run:

```sql
source database/whellco_anti_lag_events.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Admin eligibility uses `Config.AdminJobs`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Monitoring

- Client frame time is sampled every 5 seconds.
- Entity counts are monitored for peds, vehicles, and objects.
- High tick rates create lag scores.
- Excessive entity counts create lag scores.
- Rate limits prevent event, vehicle, ped, and object spam.

## Enforcement

- Warning threshold: 20 points.
- Kick threshold: 50 points.
- Automatic kicks are enabled by default.
- Lag events are logged with player, event type, score, and timestamp.

## Commands

View anti-lag status:

```text
/antistutter
```

View anti-lag information:

```text
/antilaginfo
```

## Security

- Performance monitoring runs client-side but enforcement runs server-side.
- Rate limits are validated server-side.
- Lag scores are tracked server-side.
- Lag events are logged server-side.
- Automatic kicks are enabled by default.