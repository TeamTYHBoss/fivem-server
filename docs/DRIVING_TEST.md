# Practical Driving Test System

`whellco_driving_test` provides QBCore-compatible practical driving tests, checkpoints, penalties, and test history.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_driver_license
ensure whellco_driver_exam
ensure whellco_driving_test
```

## Database

Run:

```sql
source database/whellco_driving_test.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Test participation uses `Player.PlayerData.citizenid`.
- Test fees use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Test rules

- Test fee: $250.
- Test vehicle: Blista.
- Maximum speed: 80 km/h.
- Maximum fails: 3.
- Test cooldown: 10 minutes.
- Players must be near the DMV driving test center.

## Checkpoints

The test includes six checkpoints. Players must reach each checkpoint in order without exceeding the speed limit.

## Commands

Start a driving test:

```text
/drivingtest
```

View test instructions:

```text
/drivingtestinstructions
```

## Security

- Test eligibility, cooldowns, and fees are validated server-side.
- Players must be near the DMV driving test center to start a test.
- Penalty reasons and fail counts are validated server-side.
- Test results are stored in MySQL.
- Players cannot retake a test immediately after finishing one.