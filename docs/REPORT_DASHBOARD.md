# Report Sound Alerts and Staff Dashboard

`whellco_report_dashboard` adds sound alerts and a staff dashboard for managing player reports.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_player_reports
ensure whellco_report_dashboard
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Staff eligibility uses `Config.StaffJobs`.
- Report data is read from `whellco_player_reports`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_player_reports` as dependencies.

## Sound alerts

- Staff receive a sound alert when a new report arrives.
- The alert sound is `sounds/report_alert.ogg`.
- The alert volume is configurable.
- Staff also receive an in-game notification.

## Dashboard features

- View open and claimed reports.
- Refresh the report list.
- View report details.
- Claim reports.
- Close reports with a resolution note.
- Teleport to the report location.
- Navigate report pages.

## Commands

Open the dashboard:

```text
/reportdashboard
```

View dashboard information:

```text
/dashboardinfo
```

## Security

- Staff eligibility is validated server-side.
- Report actions are validated server-side.
- Report status changes are validated server-side.
- Dashboard actions are routed through server-side permission checks.