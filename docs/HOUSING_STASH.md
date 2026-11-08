# Housing & Stash System

`whellco_housing_stash` provides QBCore-compatible housing ownership, property keys, stash storage, and property access.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_housing_stash
```

## Database

Run:

```sql
source database/whellco_housing_stash.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Property ownership uses `Player.PlayerData.citizenid`.
- Property purchases use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Stash contents are stored in MySQL.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Housing types

| Type | Price | Stash slots | Stash weight | Wardrobe slots |
|---|---:|---:|---:|---:|
| Apartment | $75,000 | 40 | 80,000 | 10 |
| House | $250,000 | 80 | 150,000 | 20 |
| Mansion | $1,250,000 | 150 | 300,000 | 40 |

## Commands

List properties:

```text
/housing
```

Purchase a property:

```text
/buynhouse apartment_1
/buynhouse house_1
```

Enter a property:

```text
/enterproperty apartment_1
```

Open a property stash:

```text
/openstash apartment_1
/openstash house_1
```

## Security

- Property ownership is tied to QBCore citizen IDs.
- Stash access is validated server-side.
- Locked properties can only be entered by owners or key holders.
- Property keys have a configurable limit.
- Stash contents are serialised as JSON and saved to MySQL.
- Only owners can purchase or grant keys.