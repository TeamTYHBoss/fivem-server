# Vehicle Tuning & Mods

`whellco_vehicle_tuning` provides QBCore-compatible vehicle tuning, performance mods, colours, ownership validation, and saved vehicle properties.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_shop
ensure whellco_vehicle_tuning
```

## Database

Run:

```sql
source database/whellco_vehicle_tuning.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Vehicle ownership uses `player_vehicles` with `citizenid` and `plate`.
- Mod purchases use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Vehicle properties use `QBCore.Functions.GetVehicleProperties(vehicle)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Tuning shops

| Shop | Location | Radius |
|---|---|---:|
| LS Customs | Strawberry | 15m |
| Benny’s Motorworks | Strawberry | 15m |

## Mods

| Mod | Max level | Price per level |
|---|---:|---:|
| Engine | 5 | $7,500 |
| Brakes | 3 | $3,500 |
| Transmission | 4 | $5,000 |
| Turbo | 1 | $25,000 |
| Suspension | 4 | $4,000 |
| Armor | 5 | $6,000 |

## Colours

| Colour | Price |
|---|---:|
| Primary | $2,500 |
| Secondary | $2,000 |

## Commands

List tuning shops:

```text
/tuninginfo
```

Apply a performance mod:

```text
/tunemods ls_customs engine 3
/tunemods bennys turbo 1
/tunemods ls_customs brakes 2
```

Apply a vehicle colour:

```text
/tunecolor ls_customs primary 255 0 0
/tunecolor bennys secondary 0 0 255
```

Save the vehicle:

```text
/savevehicle
```

## Security

- Vehicle ownership is validated server-side using QBCore citizen IDs and plates.
- Players must be near a tuning shop to apply mods or colours.
- Mod levels and RGB values are validated server-side.
- Mod purchases use a cash balance check.
- Vehicle saves use a cooldown to prevent spam.
- Mod and colour data are stored in MySQL.