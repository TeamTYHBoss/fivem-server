# Hotwire & Vehicle Theft Alerts

`whellco_vehicle_theft` provides QBCore-compatible hotwiring, theft alerts, police notifications, and stolen vehicle records.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_chop_shop
ensure whellco_vehicle_theft
```

## Database

Run:

```sql
source database/whellco_vehicle_theft.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police eligibility uses `Player.PlayerData.job.name == 'police'`.
- Hotwire requirement uses `Player.Functions.GetItemByName('lockpick')`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Theft rules

- Hotwire time: 15 seconds.
- Hotwire cooldown: 20 seconds.
- Theft alert cooldown: 30 seconds.
- Required item: lockpick.
- Police alert radius: 250m.
- Stolen vehicles are recorded in MySQL.

## Commands

Hotwire a vehicle:

```text
/hotwire
```

View theft information:

```text
/theftinfo
```

## Security

- Hotwire cooldowns and item requirements are validated server-side.
- Police alerts are sent only to eligible police players.
- Stolen vehicle records store thief, plate, model, and location.
- Theft alerts include thief name, plate, and coordinates.