# Teleport to Report Location

`whellco_report_teleport` lets staff teleport to the recorded location of an open or claimed report.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_player_reports
ensure whellco_report_teleport
```

## Database

Run:

```sql
source database/whellco_report_teleports.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Staff eligibility uses `Config.StaffJobs`.
- Teleport cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_player_reports` as dependencies.

## Teleport rules

- Staff jobs: `admin`, `manager`.
- Teleport cooldown: 5 seconds.
- Reports must be `open` or `claimed`.
- Teleport uses the location recorded when the report was submitted.
- Teleport actions are logged with staff ID, report ID, and timestamp.

## Commands

Teleport to a report:

```text
/gotoreport 1
/gotoreport 2
```

View teleport information:

```text
/gotoreportinfo
```

## Security

- Staff eligibility is validated server-side.
- Report ID and report status are validated server-side.
- Teleport cooldowns are validated server-side.
- Teleport actions are logged server-side.