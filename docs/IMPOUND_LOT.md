# Impound Lot System

`whellco_impound_lot` provides QBCore-compatible vehicle impounding tied to unpaid traffic-fine points, impound records, and paid releases.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_traffic_fines
ensure whellco_license_suspension
ensure whellco_impound_lot
```

## Database

Run:

```sql
source database/whellco_impound_lot.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police eligibility uses `Player.PlayerData.job.name == 'police'`.
- Vehicle ownership uses `player_vehicles` with `citizenid` and `plate`.
- Release payments use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_traffic_fines` as dependencies.

## Impound rules

- Impound fee: $2,500.
- Minimum unpaid points: 6.
- Release cooldown: 15 seconds.
- Players must be at the impound lot to release a vehicle.
- Players must pay all unpaid fines before release.
- Impounded vehicles are marked with `state = 2`.

## Commands

Impound a vehicle:

```text
/impound ABC123 Reckless driving
/impound XYZ789 Unpaid fines
```

Release a vehicle:

```text
/releasevehicle ABC123
/releasevehicle XYZ789
```

View impound information:

```text
/impoundinfo
```

## Security

- Police eligibility is validated server-side.
- Vehicle ownership is validated server-side using QBCore citizen IDs and plates.
- Unpaid point thresholds and cooldowns are validated server-side.
- Release payments use a bank balance check.
- Impound records store plate, owner, officer, reason, status, and release time.