# Chop Shop System

`whellco_chop_shop` provides QBCore-compatible vehicle chopping, stolen-vehicle bonuses, part sales, and chop records.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_shop
ensure whellco_chop_shop
```

## Database

Run:

```sql
source database/whellco_chop_shop.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Chop payouts use `Player.Functions.AddMoney('cash', amount, reason)`.
- Scrap rewards use `Player.Functions.AddItem('scrapmetal', amount)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Chop rules

- Chop cooldown: 30 seconds.
- Minimum vehicle value: $5,000.
- Stolen-vehicle bonus: 25%.
- Players must be at the chop shop.
- Players must be in a vehicle.
- Owned vehicles cannot be chopped.

## Parts

| Part | Value |
|---|---:|
| Engine | $1,500 |
| Transmission | $1,200 |
| Brakes | $800 |
| Suspension | $700 |
| Turbo | $2,500 |
| Armor | $1,000 |
| Body | $2,000 |

## Commands

Chop a vehicle:

```text
/chopvehicle stolen engine transmission
/chopvehicle stolen turbo body
/chopvehicle normal engine brakes
```

View chop information:

```text
/chopinfo
```

## Security

- Chop eligibility, cooldowns, and part values are validated server-side.
- Players must be near the chop shop and in a vehicle.
- Owned vehicles cannot be chopped.
- Stolen-vehicle status is checked server-side.
- Chop payouts and scrap rewards are handled server-side.
- Chop records store citizen ID, plate, parts, payout, and stolen status.