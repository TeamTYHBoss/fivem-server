# CCTV Camera Monitoring

`whellco_cctv_monitoring` provides CCTV camera monitoring for the manager at the strip club.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_cctv_monitoring
```

## Database

Run:

```sql
source database/whellco_cctv_views.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Manager eligibility uses `Player.PlayerData.job.name == 'manager'`.
- View cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## CCTV rules

- View cooldown: 10 seconds.
- Manager job: `manager`.
- Cameras are defined in config.
- View records store manager, camera, and timestamp.

## Commands

View a camera:

```text
/cctv 1
/cctv 2
```

View CCTV information:

```text
/cctvinfo
```

## Security

- Manager eligibility is validated server-side.
- View cooldowns are validated server-side.
- Camera selection is validated server-side.
- View records store manager, camera, and timestamp.