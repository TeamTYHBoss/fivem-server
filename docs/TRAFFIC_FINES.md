# Traffic Fines & Police Ticketing

`whellco_traffic_fines` provides QBCore-compatible traffic fines, police ticketing, fine payments, and license points.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_driver_license
ensure whellco_traffic_fines
```

## Database

Run:

```sql
source database/whellco_traffic_fines.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police eligibility uses `Player.PlayerData.job.name == 'police'`.
- Fine payments use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Fines

| Fine | Amount | Points |
|---|---:|---:|
| Speeding | $500 | 2 |
| Reckless Driving | $1,500 | 4 |
| Running a Red Light | $750 | 3 |
| Driving Without a License | $1,000 | 3 |
| Hit and Run | $5,000 | 6 |
| Driving Under the Influence | $3,000 | 5 |

## Commands

Issue a fine:

```text
/fine 2 speeding Reckless driving
/fine 3 dui Driving under the influence
/fine 4 no_license No valid license
```

Pay a fine:

```text
/payfine 1
/payfine 2
```

View fines:

```text
/myfines
```

Check license points:

```text
/licensepoints
```

View ticket information:

```text
/ticketinfo
```

## Security

- Police eligibility is validated server-side.
- Fine types, amounts, and cooldowns are validated server-side.
- Players can only pay their own fines.
- Fine payments use a bank balance check.
- Fine records store citizen ID, officer, type, amount, points, reason, and status.