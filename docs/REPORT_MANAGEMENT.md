# Report Management Commands

`whellco_report_management` provides admin commands to view and manage open player reports.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_player_reports
ensure whellco_report_management
```

## Database

Run:

```sql
source database/whellco_report_management.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Staff eligibility uses `Config.StaffJobs`.
- Report data is read from `whellco_player_reports`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_player_reports` as dependencies.

## Report workflow

- Reports start as `open`.
- Staff can claim an open report.
- Staff can close a claimed or open report with a resolution note.
- Staff can reopen a closed report.
- Reports are listed oldest first.

## Commands

View open reports:

```text
/reports
/reports 2
```

View report details:

```text
/reportview 1
```

Claim a report:

```text
/reportclaim 1
```

Close a report:

```text
/reportclose 1 Handled by staff
```

Reopen a report:

```text
/reportreopen 1
```

View report management help:

```text
/reporthelp
```

## Security

- Staff eligibility is validated server-side.
- Report IDs are validated server-side.
- Report status changes are validated server-side.
- Resolution notes are sanitised and length-limited.
- Report claims and closures are recorded in the database.