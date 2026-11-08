# Fake ID Scanner

`whellco_id_scanner` provides a fake ID scanner for club security at the entrance.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_id_scanner
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- ID checks use `Player.Functions.GetItemByName('id_card')` and `Player.Functions.GetItemByName('fake_id')`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Scan rules

- Scan cooldown: 10 seconds.
- Players must be near the club entrance.
- Valid ID requires `id_card` and no `fake_id`.
- Scan results are sent to both guard and target.

## Commands

Scan an ID:

```text
/scanid 2
/scanid 3
```

View scanner information:

```text
/idscannerinfo
```

## Security

- Security eligibility is validated server-side.
- Scan cooldowns and entrance location are validated server-side.
- ID validity is determined server-side.
- Scan records store guard, target, ID status, and validity.