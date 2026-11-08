# Automatic Off-Duty Timer for Idle Staff

`whellco_staff_idle_duty` automatically ends staff duty sessions after inactivity.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_staff_idle_duty
```

## Database

Run:

```sql
source database/whellco_staff_idle_duty_sessions.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Staff eligibility uses `Config.StaffJobs`.
- Session data is stored in MySQL.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Idle rules

- Staff jobs: `admin`, `manager`, `security`.
- Idle timeout: 15 minutes.
- Idle checks run every 60 seconds.
- Client activity reports refresh the idle timer.
- Sessions end automatically after the idle timeout.
- Sessions also end on manual duty toggle or disconnect.
- Session records store staff ID, job, start time, end time, duration, and end reason.

## Commands

Start or end duty:

```text
/duty
```

View current duty status:

```text
/dutystatus
```

View idle duty information:

```text
/idledutyinfo
```

## Security

- Staff eligibility is validated server-side.
- Idle timeout is validated server-side.
- Session duration is calculated server-side.
- Session records store staff ID, job, start time, end time, duration, and end reason.