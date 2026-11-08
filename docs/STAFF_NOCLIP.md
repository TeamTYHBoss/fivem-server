# Staff Noclip Toggle

`whellco_staff_noclip` provides an in-game noclip toggle for authorised staff.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_staff_noclip
```

## Database

Run:

```sql
source database/whellco_staff_noclip_logs.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Staff eligibility uses `Config.StaffJobs`.
- Noclip cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Noclip rules

- Staff jobs: `admin`, `manager`.
- Noclip cooldown: 2 seconds.
- Normal speed: 2.0.
- Fast speed: 8.0 with sprint key.
- Noclip toggles collision and invincibility.
- Noclip usage is logged with staff ID, action, and timestamp.

## Commands

Toggle noclip:

```text
/noclip
```

View noclip information:

```text
/noclipinfo
```

## Security

- Staff eligibility is validated server-side.
- Noclip cooldowns are validated server-side.
- Noclip usage is logged server-side.
- Noclip is restricted to authorised staff jobs.