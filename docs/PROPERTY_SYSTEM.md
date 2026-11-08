# Player Housing & Property System

`whellco_property` provides QBCore-compatible property ownership, keys, locking, purchases, and property access.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_property
```

## Database

Run:

```sql
source database/whellco_property.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Property ownership uses `Player.PlayerData.citizenid`.
- Property purchases use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Property types

| Type | Price | Rent | Storage | Garage slots |
|---|---:|---:|---:|---:|
| Apartment | $75,000 | $2,500 | 50 | 1 |
| House | $250,000 | $7,500 | 100 | 2 |
| Mansion | $1,250,000 | $25,000 | 200 | 6 |

## Commands

List properties:

```text
/properties
```

Purchase a property:

```text
/buyproperty apartment_1
/buyproperty house_1
```

Lock or unlock a property:

```text
/propertylock apartment_1
```

Give a property key:

```text
/propertykey apartment_1 CITIZEN_ID
```

## Security

- Property ownership is tied to QBCore citizen IDs.
- Purchases are validated server-side.
- Locked properties can only be entered by the owner or key holders.
- Property keys have a configurable limit.
- Property data and keys are stored in MySQL.
- Only owners can lock properties or grant keys.