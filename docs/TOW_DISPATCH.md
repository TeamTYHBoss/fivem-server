# Automatic Tow Truck Dispatch

`whellco_tow_dispatch` provides QBCore-compatible tow truck dispatch, manual recovery requests, and automatic dispatch after impounds.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_traffic_fines
ensure whellco_impound_lot
ensure whellco_tow_dispatch
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Tow eligibility uses `Player.PlayerData.job.name == 'towtruck'`.
- Dispatch notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_impound_lot` as dependencies.

## Dispatch rules

- Tow job: `towtruck`.
- Tow truck model: `flatbed`.
- Dispatch cooldown: 30 seconds.
- Automatic dispatch is enabled after impounds.
- Tow drivers receive the requester name, location, and reason.

## Commands

Request a tow:

```text
/requesttow Vehicle broken down
/requesttow Vehicle involved in collision
```

Check available tow drivers:

```text
/towdrivers
```

View tow information:

```text
/towinfo
```

## Security

- Tow eligibility is validated server-side.
- Dispatch cooldowns prevent spam.
- Automatic dispatch is triggered only after a valid impound event.
- Tow drivers receive dispatch data server-side.
- Dispatch records include requester, location, and reason.