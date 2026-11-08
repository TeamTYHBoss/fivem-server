# Police Dispatch Alerts for Failed Lockpicks

`whellco_lockpick_alerts` provides QBCore-compatible police dispatch alerts when lockpick attempts fail.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_lockpick_penalties
ensure whellco_lockpick_alerts
```

## Database

Run:

```sql
source database/whellco_lockpick_alerts.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police eligibility uses `Player.PlayerData.job.name == 'police'`.
- Alerts are sent only to police within the configured radius.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_lockpick_penalties` as dependencies.

## Alert rules

- Alert cooldown: 30 seconds.
- Alert radius: 200m.
- Alerts include suspect name, lockpick type, and coordinates.
- Alerts are rate-limited.

## Commands

Test a failed lockpick alert:

```text
/testfailedlockpick
```

View alert information:

```text
/lockpickalertinfo
```

## Security

- Police eligibility and alert radius are validated server-side.
- Alert cooldowns prevent spam.
- Alert records store suspect, lockpick type, and coordinates.