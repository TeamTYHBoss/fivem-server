# DJ Booth Song Request System

`whellco_dj_requests` provides a song request system for the DJ booth.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_dj_requests
```

## Database

Run:

```sql
source database/whellco_dj_requests.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- DJ eligibility uses `Player.PlayerData.job.name == 'dj'`.
- Request cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Request rules

- Request cooldown: 30 seconds.
- Request price: $500.
- DJ job: `dj`.
- Songs are defined in config.
- Request records store patron, song, price, and timestamp.

## Commands

Request a song:

```text
/songrequest 1
/songrequest 2
```

View request information:

```text
/songrequestinfo
```

## Security

- Song selection is validated server-side.
- Request cooldowns are validated server-side.
- Payment is validated server-side.
- Request records store patron, song, price, and timestamp.