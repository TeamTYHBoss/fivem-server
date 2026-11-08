# Bouncer Ejection Command

`whellco_bouncer_eject` provides a bouncer ejection command for club security.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_bouncer_eject
```

## Database

Run:

```sql
source database/whellco_bouncer_ejections.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- Ejection cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Ejection rules

- Ejection cooldown: 15 seconds.
- Security job: `security`.
- Ejected players are moved to the eject location.
- Ejection records store guard, target, reason, and timestamp.

## Commands

Eject a player:

```text
/eject 2 Disruptive behaviour
/eject 3 Fighting
```

View ejection information:

```text
/ejectinfo
```

## Security

- Security eligibility is validated server-side.
- Ejection cooldowns are validated server-side.
- Ejection reasons are validated server-side.
- Ejection records store guard, target, reason, and timestamp.