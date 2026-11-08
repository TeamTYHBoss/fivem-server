# Vehicle Shop & Dealership

`whellco_vehicle_shop` provides QBCore-compatible vehicle purchases, dealership locations, plates, taxes, and transaction records.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_shop
```

## Database

Run:

```sql
source database/whellco_vehicle_shop.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Vehicle purchases use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Vehicle ownership uses `player_vehicles` with `citizenid` and `plate`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Dealerships

| Dealership | Location | Categories |
|---|---|---|
| Premium Deluxe Motorsport | Downtown | Cars, sports, luxury |
| Benny’s Motorworks | Strawberry | Cars, muscle |

## Vehicles

| Vehicle | Price | Category | Dealership |
|---|---:|---|---|
| Adder | $1,000,000 | Sports | PDM |
| Zentorno | $725,000 | Sports | PDM |
| Dominator | $45,000 | Muscle | Benny’s |
| Sultan | $35,000 | Cars | Benny’s |

## Commands

List vehicles:

```text
/vehicles
```

Purchase a vehicle:

```text
/buyvehicle pdm adder
/buyvehicle bennys sultan
```

View dealerships:

```text
/dealerinfo
```

## Security

- Vehicle availability and dealership association are validated server-side.
- Players must be near the dealership to purchase.
- Purchases use a cooldown to prevent spam.
- Plates are generated server-side.
- Vehicle ownership is stored in QBCore’s `player_vehicles` table.
- Transaction records store citizen ID, dealership, vehicle, plate, price, tax, and total.