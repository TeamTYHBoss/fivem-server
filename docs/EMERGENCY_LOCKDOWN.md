# Emergency Lockdown System

`whellco_emergency_lockdown` provides an emergency lockdown system for club doors.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_emergency_lockdown
```

## Database

Run:

```sql
source database/whellco_lockdown_events.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Authorised jobs are `manager` and `security`.
- Lockdown cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Lockdown rules

- Lockdown cooldown: 30 seconds.
- Authorised jobs: `manager`, `security`.
- Lockdown affects all configured doors.
- Lockdown state is broadcast to all players.

## Commands

Toggle emergency lockdown:

```text
/lockdown
```

View lockdown information:

```text
/lockdowninfo
```

## Security

- Authorisation is validated server-side.
- Lockdown cooldowns are validated server-side.
- Lockdown state is broadcast server-side.
- Lockdown events store staff, action, and timestamp.