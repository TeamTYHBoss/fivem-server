# Emergency Dispatch Notifications

`whellco_dispatch` provides QBCore-native dispatch notifications, GPS waypoint routing, and emergency-call routing for police, fire, and EMS.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_dispatch
```

## GPS routing

```lua
Config.GpsRouting = {
    enabled = true,
    autoRouteHighPriority = true,
    routeTimeoutSeconds = 180,
    waypointColor = 38,
    clearWaypointOnArrival = true,
    arrivalDistance = 25.0
}
```

- High-priority calls automatically set a GPS waypoint.
- Players can manually set a route with `/dispatchroute [call_id]`.
- Routes expire after 180 seconds.
- Routes clear automatically when the player comes within 25 metres.
- Players can clear all active routes with `/dispatchclearroute`.

## Commands

Send a dispatch call:

```text
/dispatch robbery armed suspect near Legion Square
/dispatch medical_emergency unconscious player near Grove Street
/dispatch structure_fire large fire at the docks
```

Set a GPS route:

```text
/dispatchroute 1
```

Clear all active GPS routes:

```text
/dispatchclearroute
```

Clear a dispatch call:

```text
/dispatchclear 1
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Eligible responders are selected through `QBCore.Functions.GetQBCorePlayers()`.
- Job filtering uses `Player.PlayerData.job.name`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` as a dependency.

## Security

- Dispatch calls are validated server-side.
- GPS routes are only available to players whose QBCore job is eligible for the call.
- Call details are limited to 180 characters.
- Players can only clear calls assigned to their QBCore job.
- The dispatch cooldown prevents repeated calls from the same player.