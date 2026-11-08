# Roadside Repair Mechanic Dispatch

`whellco_mechanic_dispatch` provides QBCore-compatible roadside mechanic dispatch, repair jobs, payments, and dispatch records.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_mechanic_dispatch
```

## Database

Run:

```sql
source database/whellco_mechanic_dispatch.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Mechanic eligibility uses `Player.PlayerData.job.name == 'mechanic'`.
- Repair payments use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Mechanic payouts use `Player.Functions.AddMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Repair types

| Repair | Price | Duration |
|---|---:|---:|
| Engine Repair | $1,500 | 30 seconds |
| Body Repair | $1,000 | 20 seconds |
| Tyre Repair | $750 | 15 seconds |
| Full Repair | $3,000 | 60 seconds |

## Commands

Request roadside assistance:

```text
/callmechanic engine Engine overheating
/callmechanic body Body damage
/callmechanic tyres Flat tyre
/callmechanic full Vehicle breakdown
```

Perform a repair:

```text
/repairvehicle 2 engine
/repairvehicle 3 body
/repairvehicle 4 tyres
/repairvehicle 5 full
```

View repair types:

```text
/mechanicinfo
```

View dispatch information:

```text
/mechanicdispatchinfo
```

## Security

- Mechanic eligibility is validated server-side.
- Repair types, cooldowns, and payments are validated server-side.
- Customers must have enough cash before repairs begin.
- Mechanic payouts are handled server-side.
- Dispatch records store requester, mechanic, repair type, price, status, and reason.