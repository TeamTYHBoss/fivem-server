# Staff Duty Timer and Session Tracker

`whellco_staff_duty` provides a duty timer and session tracker for staff.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_staff_duty
```

## Database

Run:

```sql
source database/whellco_staff_duty_sessions.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Staff eligibility uses `Config.StaffJobs`.
- Session data is stored in MySQL.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Duty rules

- Staff jobs: `admin`, `manager`, `security`.
- Duty sessions start with `/duty`.
- Duty sessions end with `/duty` again.
- Sessions automatically close when a staff member disconnects.
- Session duration is saved every 60 seconds.
- Duty records store staff ID, job, start time, end time, and duration.

## Commands

Start or end duty:

```text
/duty
```

View current duty status:

```text
/dutystatus
```

View duty information:

```text
/dutyinfo
```

## Security

- Staff eligibility is validated server-side.
- Duty sessions are tracked server-side.
- Session duration is calculated server-side.
- Duty records store staff ID, job, start time, end time, and duration.