# Realistic Vehicle Handling & Tuning

`whellco_vehicle_handling` provides QBCore-compatible vehicle performance tuning, handling profiles, and persistent vehicle setup.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_handling
```

## Database

Run:

```sql
source database/whellco_vehicle_handling.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Vehicle ownership uses `player_vehicles.plate`.
- Mechanic permission uses `Player.PlayerData.job.name` and `Player.PlayerData.job.grade.level`.
- Tuning costs use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Tuning categories

| Category | Max level | Base cost |
|---|---:|---:|
| Engine | 5 | $2,500 |
| Brakes | 3 | $1,500 |
| Transmission | 4 | $2,000 |
| Suspension | 4 | $1,200 |
| Turbo | 4 | $3,500 |
| Tires | 5 | $800 |
| Armor | 5 | $4,000 |

## Handling profiles

| Profile | Focus |
|---|---|
| Street | Balanced daily-driving handling |
| Sport | Improved grip, braking, and acceleration |
| Race | Maximum performance, grip, and braking response |

## Commands

Apply performance tuning:

```text
/vehicletune ABC123 engine 3
/vehicletune ABC123 brakes 2
/vehicletune ABC123 turbo 1
```

Apply a handling profile:

```text
/vehiclehandling ABC123 street
/vehiclehandling ABC123 sport
/vehiclehandling ABC123 race
```

## Security

- Only QBCore mechanic jobs can apply tuning or handling profiles.
- Tuning level and category are validated server-side.
- Vehicle ownership is checked against `player_vehicles.plate`.
- Tuning costs are charged through QBCore bank balance.
- Handling and tuning settings are persisted in MySQL.