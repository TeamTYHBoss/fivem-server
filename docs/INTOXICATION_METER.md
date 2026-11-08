# Patron Intoxication Level Meter

`whellco_intoxication_meter` provides a patron intoxication level meter for club security.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_intoxication_meter
```

## Database

Run:

```sql
source database/whellco_intoxication_checks.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- Intoxication levels use `Config.Levels`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Intoxication rules

- Check cooldown: 10 seconds.
- Maximum intoxication: 100.
- Intoxication decay: 5 per minute.
- Security job: `security`.
- Check records store guard, target, intoxication, level, and timestamp.

## Commands

Check intoxication:

```text
/intoxication 2
/intoxication 3
```

View intoxication information:

```text
/intoxicationinfo
```

## Security

- Security eligibility is validated server-side.
- Check cooldowns are validated server-side.
- Intoxication levels are validated server-side.
- Check records store guard, target, intoxication, level, and timestamp.