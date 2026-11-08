# Bouncer ID Check

`whellco_bouncer_id_check` provides a bouncer ID check at the front door.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_bouncer_id_check
```

## Database

Run:

```sql
source database/whellco_bouncer_id_checks.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- ID checks use `Player.Functions.GetItemByName('id_card')` and `Player.Functions.GetItemByName('fake_id')`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Check rules

- Check cooldown: 10 seconds.
- Players must be near the front door.
- Valid ID requires `id_card` and no `fake_id`.
- Check results are sent to both guard and target.
- Check records store guard, target, ID status, and result.

## Commands

Check an ID:

```text
/checkid 2
/checkid 3
```

View check information:

```text
/checkidinfo
```

## Security

- Security eligibility is validated server-side.
- Check cooldowns and front-door location are validated server-side.
- ID validity is determined server-side.
- Check records store guard, target, ID status, and result.