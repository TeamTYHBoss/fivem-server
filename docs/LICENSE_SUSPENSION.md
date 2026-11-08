# DMV License Suspension

`whellco_license_suspension` automatically suspends QBCore driver licenses when a player reaches the configured unpaid traffic-fine point threshold.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_driver_license
ensure whellco_traffic_fines
ensure whellco_license_suspension
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- License ownership uses `Player.PlayerData.citizenid`.
- Reinstatement payments use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_traffic_fines` as dependencies.

## Suspension rules

- Suspension threshold: 12 unpaid points.
- Suspension duration: 24 hours.
- Reinstatement fee: $2,500.
- Suspended license types: car, bike, truck, boat, pilot.
- Players must pay all unpaid fines before reinstatement.

## Commands

Check unpaid points and trigger suspension:

```text
/checkpoints
```

Reinstate suspended licenses:

```text
/reinstate
```

## Security

- Unpaid points are calculated server-side.
- License suspension and reinstatement are validated server-side.
- Players cannot reinstate licenses while unpaid points remain at or above the threshold.
- Reinstatement requires a bank balance check.
- License status is stored in the `whellco_driver_licenses` table.