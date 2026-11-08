# Driver License & DMV System

`whellco_driver_license` provides QBCore-compatible driver licenses, DMV purchases, license status, and police revocation.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_driver_license
```

## Database

Run:

```sql
source database/whellco_driver_license.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- License ownership uses `Player.PlayerData.citizenid`.
- License purchases use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Police revocation uses `Player.PlayerData.job.name == 'police'`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Licenses

| License | Price | Test time |
|---|---:|---:|
| Car | $500 | 120 seconds |
| Bike | $350 | 90 seconds |
| Truck | $1,500 | 180 seconds |
| Boat | $1,000 | 120 seconds |
| Pilot | $5,000 | 240 seconds |

## Commands

List licenses:

```text
/licenses
```

Purchase a license:

```text
/buylicense car
/buylicense bike
/buylicense truck
/buylicense boat
/buylicense pilot
```

Revoke a license:

```text
/revokelicense CITIZENID car Reckless driving
```

View DMV information:

```text
/dmvinfo
```

## Security

- License purchases and revocations are validated server-side.
- Players must be near the DMV to purchase a license.
- Duplicate licenses are prevented by a unique citizen/license index.
- Only police can revoke licenses.
- Revocations require a reason.
- License status is stored in MySQL.