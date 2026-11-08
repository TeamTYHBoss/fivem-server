# Fuel & Gas Station System

`whellco_fuel_station` provides QBCore-compatible fuel levels, gas stations, refuelling, ownership checks, and fuel persistence.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_shop
ensure whellco_fuel_station
```

## Database

Run:

```sql
source database/whellco_fuel_station.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Vehicle ownership uses `player_vehicles` with `citizenid` and `plate`.
- Fuel purchases use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Fuel levels are stored in MySQL.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Gas stations

| Station | Location | Radius |
|---|---|---:|
| Xero Gas Station | Sandy Shores | 15m |
| RON Gas Station | Sandy Shores | 15m |
| LS Customs Gas Station | Strawberry | 15m |

## Fuel rules

- Maximum fuel level: 100%.
- Starting fuel level: 35%.
- Fuel price: $2.25 per litre.
- Refuelling cooldown: 3 seconds.
- Players must be near a gas station.
- Players must own the vehicle being refuelled.

## Commands

List gas stations:

```text
/fuelinfo
```

Refuel a vehicle:

```text
/fuel xero_gas 20
/fuel ron_gas 35
/fuel ls_customs_gas 50
```

Check fuel level:

```text
/checkfuel
```

## Security

- Vehicle ownership is validated server-side using QBCore citizen IDs and plates.
- Players must be near a gas station to refuel.
- Fuel amounts, tank capacity, and cooldowns are validated server-side.
- Fuel purchases use a cash balance check.
- Fuel levels are stored in MySQL.